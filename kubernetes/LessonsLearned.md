# Kubernetes + Terraform — Lessons Learned

Bugs encountered while applying the `kubernetes/` Terraform module against a
local **kind** cluster, their root causes, and the fixes applied.

---

## Bug 1 — PVC Deadlock: `context deadline exceeded`

### Bug 1 — Error Message

```text
module.storage.kubernetes_persistent_volume_claim_v1.minio: Still creating... [05m09s elapsed]

Error: client rate limiter Wait returned an error: context deadline exceeded

  with module.storage.kubernetes_persistent_volume_claim_v1.minio,
  on modules/storage/main.tf line 64, in resource "kubernetes_persistent_volume_claim_v1" "minio":
  64: resource "kubernetes_persistent_volume_claim_v1" "minio" {
```

### Bug 1 — Root Cause

The cluster's default `StorageClass` uses `WaitForFirstConsumer` volume binding
mode:

```bash
$ kubectl get storageclass
NAME                 PROVISIONER             RECLAIMPOLICY   VOLUMEBINDINGMODE
standard (default)   rancher.io/local-path   Delete          WaitForFirstConsumer
```

`WaitForFirstConsumer` means the PersistentVolume is **not provisioned and the
PVC is not bound until a Pod that references it is actually scheduled onto a
node**. This is by design — it lets the scheduler pick a node before locking
the storage to a specific zone.

The original code had `wait_until_bound = true` on the PVC resource:

```hcl
# ❌ BEFORE — blocks Terraform until the PVC is bound
resource "kubernetes_persistent_volume_claim_v1" "minio" {
  ...
  wait_until_bound = true   # default
}
```

Because Terraform creates resources **sequentially within a dependency chain**,
it was waiting for the PVC to bind before creating the Deployment. But the PVC
can only bind once a Pod is scheduled — and no Pod could be scheduled because
the Deployment had not been created yet.

**Result: a circular wait / deadlock** — Terraform blocked forever until the
provider's context deadline (5 minutes) fired.

### Bug 1 — Fix

```hcl
# ✅ AFTER — Terraform creates the PVC and moves on immediately
resource "kubernetes_persistent_volume_claim_v1" "minio" {
  ...
  wait_until_bound = false
}
```

With `wait_until_bound = false`, Terraform submits the PVC to the Kubernetes
API and proceeds to create the Deployment. Once a Pod from the Deployment is
scheduled, Kubernetes triggers the `local-path` provisioner, which creates the
PersistentVolume and binds it — all transparently, without Terraform needing
to wait.

### Bug 1 — Key Takeaway

> Always check the `VolumeBindingMode` of your default `StorageClass`.  
> If it is `WaitForFirstConsumer`, set `wait_until_bound = false` on every PVC
> managed by Terraform — otherwise you will deadlock on the first apply.

---

## Bug 2 — Tomcat CrashLoopBackOff: `Invalid initial heap size`

### Bug 2 — Error Message

The Tomcat pods started but immediately crashed with exit code 1:

```bash
$ kubectl logs webapp-66ff865d98-fqjtd --previous -n terraform

Invalid initial heap size: -Xms256Mi
Error: Could not create the Java Virtual Machine.
Error: A fatal exception has occurred. Program will exit.
```

### Bug 2 — Root Cause

The `CATALINA_OPTS` environment variable in the ConfigMap was built by
interpolating the Terraform variable `var.memory_request`, whose value is the
Kubernetes resource quantity string `"256Mi"`:

```hcl
# ❌ BEFORE — injects Kubernetes quantity notation into a JVM flag
data = {
  CATALINA_OPTS = "-Xms${var.memory_request} -Xmx${var.memory_limit}"
  # resolves to: -Xms256Mi -Xmx512Mi  ← INVALID for the JVM
}
```

Kubernetes resource quantities use [binary SI suffixes][k8s-quantities]:
`Ki`, `Mi`, `Gi` — but the **JVM heap flags** (`-Xms`, `-Xmx`) use a
completely different notation: `k`, `m`, `g` (case-insensitive, no `i`).

| Context | Valid notation | Example |
| --- | --- | --- |
| Kubernetes `resources.requests/limits` | `Ki`, `Mi`, `Gi` | `256Mi` |
| JVM `-Xms` / `-Xmx` flags | `k`, `m`, `g` | `256m` |

Passing `256Mi` to the JVM causes an immediate fatal error before Tomcat even
starts, hence the instant crash and `CrashLoopBackOff`.

### Bug 2 — Fix

```hcl
# ✅ AFTER — hardcoded JVM-compatible notation
data = {
  CATALINA_OPTS = "-Xms256m -Xmx512m"
  APP_ENV       = var.environment
  APP_PORT      = tostring(var.container_port)
}
```

### Bug 2 — Key Takeaway

> **Never interpolate Kubernetes resource quantity strings directly into JVM
> flags.** The `Mi` / `Gi` suffix is specific to the Kubernetes API and is not
> understood by the JVM. Use separate variables (or hardcoded values) for JVM
> heap sizes and keep them in plain megabytes (`m`) or gigabytes (`g`).

---

## Bug 3 — Webapp Deployment Timeout: `0 replicas Ready`

### Bug 3 — Error Message

```text
Error: Waiting for rollout to finish: 2 replicas wanted; 0 replicas Ready

  with module.webapp.kubernetes_deployment_v1.webapp,
  on modules/webapp/main.tf line 35, in resource "kubernetes_deployment_v1" "webapp":
  35: resource "kubernetes_deployment_v1" "webapp" {
```

### Bug 3 — Root Cause

Two contributing factors:

1. **Original timeout too short** — the Deployment `timeouts` block was set to
   `create = "3m"`. On a local cluster pulling the `tomcat:10-jre17` image for
   the first time (≈ 300 MB), combined with JVM startup time, 3 minutes was
   not enough.

2. **HTTP probe returning 404** — the liveness and readiness probes used
   `http_get { path = "/" port = 8080 }`. The official `tomcat:10-jre17` image
   ships with an **empty `webapps/` directory** — the sample apps (`ROOT`,
   `manager`, etc.) live in `webapps.dist/` and are not served by default.
   A `GET /` against an empty Tomcat returns `404`, which Kubernetes treats as
   a probe failure, keeping all pods in a non-Ready state indefinitely.

```hcl
# ❌ BEFORE — HTTP probe fails (404) on default Tomcat image
liveness_probe {
  http_get {
    path = "/"    # returns 404 on tomcat:10-jre17
    port = 8080
  }
  initial_delay_seconds = 30
}

timeouts {
  create = "3m"   # too short for image pull + JVM startup
}
```

### Bug 3 — Fix

Switch probes from `http_get` to `tcp_socket`. A TCP socket probe only checks
that the port is **open and accepting connections** — it does not care about
the HTTP response code. Tomcat binds port 8080 as soon as it finishes starting,
regardless of whether any web application is deployed.

```hcl
# ✅ AFTER — TCP probe succeeds as soon as Tomcat's port opens
liveness_probe {
  tcp_socket {
    port = var.container_port   # 8080
  }
  initial_delay_seconds = 30
  period_seconds        = 10
  failure_threshold     = 3
}

readiness_probe {
  tcp_socket {
    port = var.container_port
  }
  initial_delay_seconds = 15
  period_seconds        = 5
}

timeouts {
  create = "10m"   # enough time for image pull + JVM startup
  update = "10m"
  delete = "5m"
}
```

### Bug 3 — Key Takeaway

> The official `tomcat:10-*` Docker images serve **no content at `/` by
> default**. Always use `tcp_socket` probes (or a known-good HTTP path such as
> `/manager/status` after proper setup) rather than `http_get { path = "/" }`.
>
> As a general rule, set Deployment `timeouts.create` to at least **10 minutes**
> for any workload that pulls a sizeable image on a local cluster.

---

## Summary Table

| # | Error | Root Cause | Fix |
| --- | --- | --- | --- |
| 1 | `context deadline exceeded` on PVC | `WaitForFirstConsumer` StorageClass + `wait_until_bound = true` → circular dependency | `wait_until_bound = false` |
| 2 | `Invalid initial heap size: -Xms256Mi` | Kubernetes quantity suffix (`Mi`) interpolated directly into a JVM flag | Hardcode JVM flags with plain units: `-Xms256m -Xmx512m` |
| 3 | `0 replicas Ready` / timeout | HTTP probe returns 404 on default Tomcat image + 3-minute timeout too short | Switch to `tcp_socket` probes + increase `timeouts.create` to `10m` |
| 4 | HPA `FailedGetResourceMetric` | `metrics-server` not installed in kind — `metrics.k8s.io` API unavailable | Install metrics-server + patch `--kubelet-insecure-tls` for kind |

---

## Bug 4 — HPA `FailedGetResourceMetric`: metrics API unavailable

### Bug 4 — Error Message

```text
HorizontalPodAutoscaler  webapp-hpa  terraform  FailedGetResourceMetric
failed to get cpu utilization: unable to get metrics for resource cpu:
unable to fetch metrics from resource metrics API:
the server could not find the requested resource (get pods.metrics.k8s.io)
```

### Bug 4 — Root Cause

The HPA controller reads pod CPU/memory via the `metrics.k8s.io` API group,
which is served by **metrics-server**. Kind clusters do **not** ship with
metrics-server pre-installed, so the API group simply does not exist.

Additionally, kind uses **self-signed TLS certificates** for the kubelet.
The default metrics-server build rejects self-signed certs, so even after
installing it, it would fail to scrape unless the insecure-TLS flag is set.

### Bug 4 — Fix

**Step 1** — Install metrics-server:

```bash
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
```

**Step 2** — Patch in `--kubelet-insecure-tls` (required for kind):

```bash
kubectl patch deployment metrics-server -n kube-system \
  --type='json' \
  -p='[{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--kubelet-insecure-tls"}]'
```

**Step 3** — Wait for rollout:

```bash
kubectl rollout status deployment/metrics-server -n kube-system
```

**Verification** — HPA should now show real CPU metrics:

```text
NAME        REFERENCE           TARGETS       MINPODS  MAXPODS  REPLICAS
webapp-hpa  Deployment/webapp   cpu: 0%/70%   2        6        2
```

### Bug 4 — Key Takeaway

> Kind clusters ship **without metrics-server**. Any workload that uses HPA
> with CPU/memory targets will report `FailedGetResourceMetric` until
> metrics-server is installed.
>
> Always add `--kubelet-insecure-tls` to the metrics-server deployment on kind —
> the kubelet uses self-signed certs that metrics-server will otherwise reject.

---

## Successful Apply Output

After all three fixes, all 10 resources were created in under 40 seconds:

```text
module.webapp.kubernetes_deployment_v1.webapp: Creation complete after 28s [id=terraform/webapp]
module.storage.kubernetes_deployment_v1.minio: Creation complete after 38s [id=terraform/minio]

Apply complete! Resources: 10 added, 0 changed, 0 destroyed.

Outputs:

minio_access_key      = "minioadmin"
minio_console_url     = "http://localhost:30901"
minio_s3_url          = "http://localhost:30900"
namespace             = "terraform"
webapp_url            = "http://localhost:30080"
```

[k8s-quantities]: https://kubernetes.io/docs/reference/kubernetes-api/common-definitions/quantity/
