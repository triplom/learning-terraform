# -----------------------------------------------------------------------------
# storage module — MinIO S3-compatible object storage
#
# Kubernetes equivalent of:
#   aws/  →  aws_s3_bucket + aws_s3_bucket_versioning
#   azure/ → azurerm_storage_account + azurerm_storage_container
#   local/ → docker_container.minio + docker_volume.minio_data
#
# Resources created:
#   • kubernetes_secret_v1              — MinIO root credentials (Opaque)
#   • kubernetes_config_map_v1          — Non-sensitive MinIO settings
#   • kubernetes_persistent_volume_claim_v1 — Durable data volume
#   • kubernetes_deployment_v1          — Single MinIO pod (Recreate strategy)
#   • kubernetes_service_v1             — NodePort for S3 API + web console
# -----------------------------------------------------------------------------

# ---------------------------------------------------------------------------
# Secret — MinIO root credentials (never stored in plain text)
# ---------------------------------------------------------------------------
resource "kubernetes_secret_v1" "minio" {
  metadata {
    name      = "${var.app_name}-secret"
    namespace = var.namespace
    labels = {
      app         = var.app_name
      environment = var.environment
      managed-by  = "terraform"
    }
  }

  # Values are base64-encoded automatically by the provider
  data = {
    root-user     = var.minio_root_user
    root-password = var.minio_root_password
  }

  type = "Opaque"
}

# ---------------------------------------------------------------------------
# ConfigMap — non-sensitive MinIO settings
# ---------------------------------------------------------------------------
resource "kubernetes_config_map_v1" "minio" {
  metadata {
    name      = "${var.app_name}-config"
    namespace = var.namespace
    labels = {
      app         = var.app_name
      environment = var.environment
      managed-by  = "terraform"
    }
  }

  data = {
    MINIO_BROWSER      = "on"
    MINIO_DEFAULT_BUCKETS = var.bucket_name
  }
}

# ---------------------------------------------------------------------------
# PersistentVolumeClaim — durable storage for MinIO's /data directory
# Mirrors: docker_volume.minio_data, azurerm_storage_account, aws_s3_bucket
# ---------------------------------------------------------------------------
resource "kubernetes_persistent_volume_claim_v1" "minio" {
  metadata {
    name      = "${var.app_name}-pvc"
    namespace = var.namespace
    labels = {
      app         = var.app_name
      environment = var.environment
      managed-by  = "terraform"
    }
  }

  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = var.storage_size
      }
    }
  }

  # IMPORTANT: the "standard" StorageClass (rancher.io/local-path) uses
  # WaitForFirstConsumer binding mode — the PVC only binds once a pod that
  # references it is actually scheduled on a node.  Setting wait_until_bound
  # = true here creates a deadlock: Terraform blocks waiting for binding, so
  # the Deployment is never created, so no pod is ever scheduled, so the PVC
  # never binds.  Set to false so Terraform moves on and lets the pod trigger
  # the binding naturally.
  wait_until_bound = false
}

# ---------------------------------------------------------------------------
# Deployment — MinIO object storage server
# ---------------------------------------------------------------------------
resource "kubernetes_deployment_v1" "minio" {
  metadata {
    name      = var.app_name
    namespace = var.namespace
    labels = {
      app         = var.app_name
      environment = var.environment
      managed-by  = "terraform"
    }
  }

  spec {
    # Single replica — MinIO in standalone mode (use StatefulSet for HA)
    replicas = 1

    selector {
      match_labels = {
        app = var.app_name
      }
    }

    # Recreate ensures the PVC is fully released before a new pod mounts it
    strategy {
      type = "Recreate"
    }

    template {
      metadata {
        labels = {
          app         = var.app_name
          environment = var.environment
        }
      }

      spec {
        container {
          name  = "minio"
          image = var.image

          # Start in server mode; expose the web console on :9001
          args = ["server", "/data", "--console-address", ":9001"]

          port {
            name           = "s3"
            container_port = 9000
            protocol       = "TCP"
          }

          port {
            name           = "console"
            container_port = 9001
            protocol       = "TCP"
          }

          # Sensitive credentials sourced from the Secret
          env {
            name = "MINIO_ROOT_USER"
            value_from {
              secret_key_ref {
                name = kubernetes_secret_v1.minio.metadata[0].name
                key  = "root-user"
              }
            }
          }

          env {
            name = "MINIO_ROOT_PASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret_v1.minio.metadata[0].name
                key  = "root-password"
              }
            }
          }

          # Non-sensitive settings from ConfigMap
          env_from {
            config_map_ref {
              name = kubernetes_config_map_v1.minio.metadata[0].name
            }
          }

          # Mount durable PVC at the data directory
          volume_mount {
            name       = "minio-data"
            mount_path = "/data"
          }

          resources {
            requests = {
              cpu    = var.cpu_request
              memory = var.memory_request
            }
            limits = {
              cpu    = var.cpu_limit
              memory = var.memory_limit
            }
          }

          liveness_probe {
            http_get {
              path = "/minio/health/live"
              port = 9000
            }
            initial_delay_seconds = 30
            period_seconds        = 20
            timeout_seconds       = 5
            failure_threshold     = 3
          }

          readiness_probe {
            http_get {
              path = "/minio/health/ready"
              port = 9000
            }
            initial_delay_seconds = 15
            period_seconds        = 10
            timeout_seconds       = 5
          }
        }

        volume {
          name = "minio-data"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim_v1.minio.metadata[0].name
          }
        }
      }
    }
  }
}

# ---------------------------------------------------------------------------
# Service — NodePort exposes the S3 API and web console on the host node
# ---------------------------------------------------------------------------
resource "kubernetes_service_v1" "minio" {
  metadata {
    name      = "${var.app_name}-svc"
    namespace = var.namespace
    labels = {
      app         = var.app_name
      environment = var.environment
      managed-by  = "terraform"
    }
  }

  spec {
    selector = {
      app = var.app_name
    }

    port {
      name        = "s3"
      port        = 9000
      target_port = 9000
      node_port   = var.s3_node_port
      protocol    = "TCP"
    }

    port {
      name        = "console"
      port        = 9001
      target_port = 9001
      node_port   = var.console_node_port
      protocol    = "TCP"
    }

    type = "NodePort"
  }
}
