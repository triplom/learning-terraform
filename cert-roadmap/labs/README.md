# Hands-On Labs

Practical labs using the existing code in this repository. All labs reference real Terraform configurations — no need to write Terraform from scratch.

> **Girus warm-ups available!** Run [`girus lab start terraform-fundamentos`](./girus-warmups.md) before Lab 1 for a guided intro.

---

## Prerequisites

```bash
# Verify Terraform is installed
terraform version

# Verify Docker is running (for local labs)
docker info

# Working directory
cd /home/triplom/terraform-cert-work
```

---

## Lab 1: Core Workflow (Objective 3)

**Time:** 30–45 minutes
**Directory:** `local/`
**Terraform version:** 1.x
**Cloud required:** No (uses Docker)

### Setup
```bash
cd /home/triplom/terraform-cert-work/local
```

### Steps

**1. Initialize**
```bash
terraform init
# Observe: provider download, lock file creation
cat .terraform.lock.hcl    # Inspect lock file
ls .terraform/providers/   # Provider binary location
```

**2. Format and Validate**
```bash
terraform fmt -check       # Check formatting (should pass)
terraform fmt -diff        # Preview any formatting changes
terraform validate         # Validate configuration
```

**3. Plan**
```bash
terraform plan             # Review proposed changes
# Observe: + symbols, resource types, attribute values
terraform plan -out=lab1.plan   # Save plan
terraform show lab1.plan        # Inspect saved plan
```

**4. Apply**
```bash
terraform apply lab1.plan       # Apply saved plan (no prompt)
# Observe: resource creation output, IDs assigned
```

**5. Inspect State**
```bash
terraform state list            # See managed resources
terraform state show docker_container.tomcat  # Inspect resource
terraform show                  # Full state view
terraform output                # View outputs (if defined)
```

**6. Refresh-Only**
```bash
terraform apply -refresh-only   # Detect any drift
# Should show: No changes (if no external modifications)
```

**7. Destroy**
```bash
terraform plan -destroy         # Preview destroy
terraform destroy -auto-approve # Destroy everything
terraform state list            # Should be empty
```

**Key concepts practiced:** init, fmt, validate, plan, apply, state inspection, refresh-only, destroy

**Expected outputs:**

```
# terraform init (excerpt)
Initializing the backend...
Initializing provider plugins...
- Finding kreuzwerker/docker versions matching "~> 3.0"...
- Installing kreuzwerker/docker v3.x.x...
Terraform has been successfully initialized!

# terraform plan (excerpt)
Plan: 4 to add, 0 to change, 0 to destroy.

# terraform state list (after apply)
docker_container.minio
docker_container.minio_init
docker_container.tomcat
docker_network.app_network

# terraform output
minio_api_url = "http://localhost:9000"
minio_console_url = "http://localhost:9001"
tomcat_url = "http://localhost:8888"

# terraform apply -refresh-only
No changes. Your infrastructure matches the configuration.
```

**Validation checklist:**

- [ ] `terraform init` completes without errors; `.terraform.lock.hcl` is created
- [ ] `terraform validate` returns "Success! The configuration is valid."
- [ ] `terraform plan` shows only additions (no changes or destroys on first run)
- [ ] `terraform state list` shows all 4 resources after apply
- [ ] `terraform output` shows accessible URLs
- [ ] `terraform apply -refresh-only` shows "No changes"
- [ ] `terraform destroy` removes all resources; `terraform state list` is empty

**Common errors:**

| Error | Cause | Fix |
|-------|-------|-----|
| `Docker daemon not running` | Docker service stopped | `sudo systemctl start docker` |
| `Error: Provider not found` | Init not run | `terraform init` first |
| `Port already allocated` | Port 8888/9000 in use | Change `tomcat_port`/`minio_port` variables |

---

## Lab 2: Variables and Outputs (Objective 4)

**Time:** 20–30 minutes
**Directory:** `local/` (or create a scratch workspace)

### Explore the existing variable setup
```bash
cd /home/triplom/terraform-cert-work/local
cat main.tf        # Observe variable references

# If variables.tf and outputs.tf exist, review them
ls *.tf
```

### Test variable precedence
```bash
# Default (from variable block)
terraform plan

# Override with -var flag
terraform plan -var="environment=staging"

# Override with environment variable (highest precedence)
export TF_VAR_environment=prod
terraform plan
unset TF_VAR_environment
```

### Use terraform console
```bash
terraform console
# Test expressions:
> upper("hello")
> length([1, 2, 3])
> format("web-%s-%02d", "app", 1)
> merge({a=1}, {b=2})
> [for i in range(3) : "server-${i}"]
> exit
```

**Key concepts practiced:** variable declaration, defaults, precedence, console for function testing

**Expected outputs:**

```
# terraform plan -var="environment=staging" (shows changed tag)
~ update in-place
  ~ docker_container.tomcat
      ~ env = [
          ~ "APP_ENV=local" -> "APP_ENV=staging"
        ]

# terraform console — function examples
> upper("hello")
"HELLO"
> length([1, 2, 3])
3
> format("web-%s-%02d", "app", 1)
"web-app-01"
> merge({a=1}, {b=2})
{
  "a" = 1
  "b" = 2
}
> [for i in range(3) : "server-${i}"]
[
  "server-0",
  "server-1",
  "server-2",
]
```

**Validation checklist:**

- [ ] `terraform plan` with no flags uses variable defaults
- [ ] `-var="environment=staging"` overrides the default value in the plan
- [ ] `TF_VAR_environment=prod` takes precedence over `-var` flag
- [ ] `terraform console` responds to `upper()`, `length()`, `format()`, `merge()`, `for` expressions

**Common errors:**

| Error | Cause | Fix |
|-------|-------|-----|
| Variable not overriding | Wrong env var name | Must be `TF_VAR_<variable_name>` exactly |
| `terraform console` hangs | No state loaded yet | Run `terraform init` first |

---

## Lab 3: State Management (Objectives 6 & 7)

**Time:** 30–45 minutes
**Directory:** `local/`

### Step 1: Apply infrastructure
```bash
cd /home/triplom/terraform-cert-work/local
terraform apply -auto-approve
```

### Step 2: Inspect state
```bash
terraform state list
terraform state show docker_container.tomcat    # Adjust to actual resource name
terraform state pull | python3 -m json.tool    # Pretty-print state JSON
```

### Step 3: Practice state mv (simulate rename)
```bash
# IMPORTANT: This is a destructive state operation — in this lab it's safe
# because we're using Docker, but understand the implications

# List resources first
terraform state list

# Move a resource (rename simulation)
# terraform state mv docker_container.tomcat docker_container.tomcat_app

# Check state after move
# terraform state list
# terraform plan   # Should show rename effect
```

### Step 4: Practice state rm
```bash
# Remove from state (resource will still exist as a Docker container)
terraform state rm docker_container.tomcat     # Adjust to actual name

# Verify: resource gone from state
terraform state list

# Verify: container still exists in Docker
docker ps

# Re-import it back
CONTAINER_ID=$(docker inspect -f '{{.Id}}' tomcat 2>/dev/null || docker ps -q --filter name=tomcat | head -1)
terraform import docker_container.tomcat "$CONTAINER_ID"

# Verify state is restored
terraform state list
terraform plan    # Should show no changes
```

### Step 5: Enable debug logging
```bash
export TF_LOG=DEBUG
export TF_LOG_PATH=/tmp/terraform-lab3.log
terraform plan
export TF_LOG=OFF

# Inspect log
wc -l /tmp/terraform-lab3.log
head -50 /tmp/terraform-lab3.log
```

**Key concepts practiced:** state list, state show, state mv, state rm, import, debug logging

**Expected outputs:**

```
# terraform state list
docker_container.minio
docker_container.minio_init
docker_container.tomcat
docker_network.app_network

# terraform state show docker_container.tomcat (excerpt)
resource "docker_container" "tomcat" {
    id    = "abc123..."
    image = "sha256:..."
    name  = "tomcat"
    ports {
        internal = 8080
        external = 8888
    }
}

# terraform state pull | python3 -m json.tool (excerpt)
{
  "version": 4,
  "terraform_version": "1.x.x",
  "serial": 3,
  "lineage": "...",
  "resources": [...]
}

# After state rm
Removed docker_container.tomcat
Successfully removed 1 resource instance(s).

# docker ps (container still exists despite state removal)
CONTAINER ID  IMAGE   COMMAND  ...  NAMES
abc123        tomcat  ...           tomcat

# After terraform import
Import successful!
```

**Validation checklist:**

- [ ] `terraform state list` shows all 4 resources after apply
- [ ] `terraform state show` displays full resource attributes
- [ ] After `state rm`, `terraform state list` no longer shows the resource
- [ ] `docker ps` confirms container still running after state removal (state != reality)
- [ ] `terraform import` successfully re-adds the container to state
- [ ] `terraform plan` shows "No changes" after import

**Common errors:**

| Error | Cause | Fix |
|-------|-------|-----|
| `state rm` fails | Mistyped resource address | Use exact address from `state list` |
| `import` fails | Wrong container ID | Use `docker inspect -f '{{.Id}}'` to get full ID |
| State locked | Previous plan/apply crashed | `terraform force-unlock <LOCK_ID>` |

---

## Lab 4: Modules (Objective 5)

**Time:** 20–30 minutes
**Directory:** `kubernetes/`

### Explore the module structure
```bash
cd /home/triplom/terraform-cert-work/kubernetes

# Root module files
ls *.tf

# Child modules
ls modules/
ls modules/webapp/
ls modules/storage/

# Understand the interface
cat modules/webapp/variables.tf    # Module inputs
cat modules/webapp/outputs.tf      # Module outputs
cat modules/webapp/main.tf         # Module resources

# See how root calls the modules
cat main.tf
```

### Inspect module sourcing
```bash
# View what modules are registered
# (After init)
terraform init
cat .terraform/modules/modules.json  # Module metadata
```

### Explore the public registry
- Browse https://registry.terraform.io/browse/modules
- Find `terraform-aws-modules/vpc/aws`
- Note: `source`, `version`, available inputs and outputs

**Key concepts practiced:** module structure, inputs/outputs, local module sourcing, init with modules

**Expected outputs:**

```
# ls modules/
storage/  webapp/

# cat modules/webapp/variables.tf (excerpt)
variable "image" {
  description = "Container image for the webapp"
  type        = string
}
variable "replicas" {
  description = "Number of pod replicas"
  type        = number
  default     = 2
}

# cat .terraform/modules/modules.json (excerpt, after init)
{
  "Modules": [
    {"Key": "webapp", "Source": "./modules/webapp", "Dir": "modules/webapp"},
    {"Key": "storage", "Source": "./modules/storage", "Dir": "modules/storage"}
  ]
}

# terraform providers (output after init)
Providers required by configuration:
└── provider[registry.terraform.io/hashicorp/kubernetes] ~> 3.0
```

**Validation checklist:**

- [ ] Module directory structure follows `variables.tf` / `main.tf` / `outputs.tf` pattern
- [ ] Root `main.tf` calls modules with `module "<name>" { source = "..." }` blocks
- [ ] `terraform init` downloads/resolves modules (even local ones need init)
- [ ] `.terraform/modules/modules.json` lists all resolved modules
- [ ] Module outputs are referenced as `module.<name>.<output>` in root

**Common errors:**

| Error | Cause | Fix |
|-------|-------|-----|
| `Module not installed` | Init not run after adding module | `terraform init` |
| `Missing required argument` | Module requires a variable | Check `variables.tf` for required vars (no default) |
| `module.webapp.output` not found | Output not declared in module | Add output block to `modules/webapp/outputs.tf` |

---

## Lab 5: Provider Versions and Lock File (Objective 2)

**Time:** 15–20 minutes
**Directory:** `local/`

```bash
cd /home/triplom/terraform-cert-work/local

# Examine provider requirements
cat main.tf | grep -A 10 "required_providers"

# Inspect the lock file
cat .terraform.lock.hcl

# Upgrade provider (if newer version available within constraint)
terraform init -upgrade

# Check if lock file changed
cat .terraform.lock.hcl

# View all providers in use
terraform providers

# View terraform and provider versions
terraform version
```

**Key concepts practiced:** version constraints, lock file, provider tiers, init -upgrade

**Expected outputs:**

```
# cat .terraform.lock.hcl
provider "registry.terraform.io/kreuzwerker/docker" {
  version     = "3.x.x"
  constraints = "~> 3.0"
  hashes = [
    "h1:...",
    "zh:...",
  ]
}

# terraform providers
Providers required by configuration:
└── provider[registry.terraform.io/kreuzwerker/docker] ~> 3.0

# terraform version
Terraform v1.x.x
on linux_amd64
+ provider registry.terraform.io/kreuzwerker/docker v3.x.x

# terraform init -upgrade (if newer patch version available)
- Installing kreuzwerker/docker v3.x.x (newer)...
```

**Validation checklist:**

- [ ] `.terraform.lock.hcl` contains `version`, `constraints`, and `hashes` for each provider
- [ ] `terraform providers` lists all providers used across the configuration
- [ ] `terraform version` shows both Terraform and provider versions
- [ ] `~> 3.0` constraint allows `3.x.x` but not `4.0.0` (pessimistic constraint operator)
- [ ] `terraform init -upgrade` can update patch versions within constraint

**Common errors:**

| Error | Cause | Fix |
|-------|-------|-----|
| Lock file conflict | Different Terraform version used | Run `terraform init -upgrade` |
| Provider not found in registry | Wrong registry path | Use exact path from provider docs |

---

## Lab 6: Workspace Commands (Objective 6)

**Time:** 15–20 minutes
**Directory:** `local/`

```bash
cd /home/triplom/terraform-cert-work/local

# Current workspace
terraform workspace show     # Should show "default"
terraform workspace list

# Create new workspace
terraform workspace new staging
terraform workspace show     # Now "staging"

# State is separate per workspace
terraform state list         # Empty in staging workspace

# Switch back
terraform workspace select default
terraform state list         # Resources visible again

# Delete staging (must be empty)
terraform workspace delete staging

# Reference workspace in console
terraform console
> terraform.workspace        # Shows current workspace name
> exit
```

**Key concepts practiced:** workspace create/select/delete, state isolation per workspace

**Expected outputs:**

```
# terraform workspace show
default

# terraform workspace list
* default

# terraform workspace new staging
Created and switched to workspace "staging"!

# terraform workspace list
  default
* staging

# terraform state list (in staging workspace — empty)
(no output)

# terraform workspace select default
Switched to workspace "default".

# terraform console > terraform.workspace
"default"

# After workspace select staging:
# terraform console > terraform.workspace
"staging"
```

**Validation checklist:**

- [ ] `terraform workspace show` returns `default` initially
- [ ] After `workspace new staging`, `workspace list` shows `* staging` (active)
- [ ] `terraform state list` in staging is empty (isolated state)
- [ ] `terraform workspace select default` restores original resources in state
- [ ] `terraform.workspace` in console returns the active workspace name
- [ ] `workspace delete staging` fails if workspace has resources in state

**Common errors:**

| Error | Cause | Fix |
|-------|-------|-----|
| `Cannot delete workspace` | Workspace has resources | `terraform destroy` in that workspace first |
| State shows resources in new workspace | `workspace new` doesn't copy state | This is correct — workspaces have isolated state |

---

## Lab 7: Import (Objective 7)

**Time:** 20–30 minutes
**Directory:** `local/`

### Create a resource outside Terraform
```bash
# Pull nginx image manually (outside Terraform)
docker pull nginx:latest

# Note the image ID
docker images nginx:latest --format "{{.ID}}"
```

### Import it into Terraform
```bash
cd /home/triplom/terraform-cert-work/local

# 1. Add HCL config for the image (in a scratch .tf file)
cat > /tmp/import_test.tf << 'EOF'
resource "docker_image" "nginx_imported" {
  name = "nginx:latest"
}
EOF
cp /tmp/import_test.tf ./nginx_import.tf

# 2. Get the image ID
IMAGE_ID=$(docker images nginx:latest --format "{{.ID}}")
echo "Image ID: $IMAGE_ID"

# 3. Import
terraform import docker_image.nginx_imported "$IMAGE_ID"

# 4. Verify no diff
terraform plan   # Should show no changes for the imported resource

# 5. Clean up
rm ./nginx_import.tf
terraform state rm docker_image.nginx_imported
```

**Key concepts practiced:** terraform import CLI syntax, post-import plan verification

**Expected outputs:**

```
# docker images nginx:latest --format "{{.ID}}"
abc123def456

# terraform import docker_image.nginx_imported abc123def456
docker_image.nginx_imported: Importing from ID "abc123def456"...
docker_image.nginx_imported: Import prepared!
  Prepared docker_image for import
docker_image.nginx_imported: Refreshing state... [id=sha256:abc123...]
Import successful!

The resources that were imported are shown above. These resources are now in
your Terraform state and will henceforth be managed by Terraform.

# terraform plan (after import — should show no changes)
docker_image.nginx_imported: Refreshing state...
No changes. Your infrastructure matches the configuration.
```

**Validation checklist:**

- [ ] Container/image exists in Docker before import attempt
- [ ] `terraform import` runs without error and confirms "Import successful!"
- [ ] `terraform state list` shows the imported resource
- [ ] `terraform plan` shows "No changes" after successful import
- [ ] `terraform state rm` cleanly removes the resource from state without destroying it

**Common errors:**

| Error | Cause | Fix |
|-------|-------|-----|
| `Error: resource address not found` | HCL block missing | Add matching `resource "docker_image" "nginx_imported" {}` block first |
| `Import failed` | Wrong ID format | Check provider docs for the expected import ID format |
| Plan shows changes after import | Config doesn't match real resource | Update HCL attributes to match `state show` output |

---

## Girus Warm-Up Labs

Before starting the labs above, use Girus for guided Terraform and AWS practice:

```bash
# Start a guided Terraform lab in Girus
girus lab start terraform-fundamentos

# Open the web interface
xdg-open http://localhost:8000
```

See [`girus-warmups.md`](./girus-warmups.md) for full step-by-step exercises.

---

## Lab Reference Summary

| Lab | Objectives | Time | Cloud Needed |
|-----|-----------|------|-------------|
| 1: Core Workflow | 3 | 30-45 min | No (Docker) |
| 2: Variables & Outputs | 4 | 20-30 min | No |
| 3: State Management | 6, 7 | 30-45 min | No (Docker) |
| 4: Modules | 5 | 20-30 min | No |
| 5: Provider Versions | 2 | 15-20 min | No |
| 6: Workspaces | 6 | 15-20 min | No |
| 7: Import | 7 | 20-30 min | No (Docker) |

**Total estimated time:** ~3.5–4 hours for all labs

---

## Lab Troubleshooting

| Issue | Solution |
|-------|---------|
| Docker not running | `sudo systemctl start docker` |
| Permission denied on Docker | `sudo usermod -aG docker $USER` then re-login |
| Provider not found | Run `terraform init` in the directory |
| State locked | `terraform force-unlock <LOCK_ID>` |
| Plan shows unexpected changes | Check if Docker containers still running |
| Import fails | Verify container/image ID is correct with `docker ps` or `docker images` |

---

*Back to: [Cert Roadmap Overview](../README.md) | [Study Plan](../study-plan/README.md)*
