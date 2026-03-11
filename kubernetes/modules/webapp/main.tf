# -----------------------------------------------------------------------------
# webapp module — Tomcat web application
#
# Resources created:
#   • kubernetes_config_map_v1          — JVM and app environment variables
#   • kubernetes_deployment_v1          — Tomcat pods with health probes
#   • kubernetes_service_v1             — NodePort service for external access
#   • kubernetes_horizontal_pod_autoscaler_v2 — CPU-based auto-scaling
# -----------------------------------------------------------------------------

# ---------------------------------------------------------------------------
# ConfigMap — runtime configuration injected as environment variables
# ---------------------------------------------------------------------------
resource "kubernetes_config_map_v1" "webapp" {
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
    # JVM heap: use plain megabytes (e.g. "256m"), NOT Kubernetes quantity notation ("256Mi")
    CATALINA_OPTS = "-Xms256m -Xmx512m"
    APP_ENV       = var.environment
    APP_PORT      = tostring(var.container_port)
  }
}

# ---------------------------------------------------------------------------
# Deployment — Tomcat web server pods
# ---------------------------------------------------------------------------
resource "kubernetes_deployment_v1" "webapp" {
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
    replicas = var.replicas

    selector {
      match_labels = {
        app = var.app_name
      }
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
          name  = "tomcat"
          image = var.image

          port {
            name           = "http"
            container_port = var.container_port
            protocol       = "TCP"
          }

          # Inject config via ConfigMap
          env_from {
            config_map_ref {
              name = kubernetes_config_map_v1.webapp.metadata[0].name
            }
          }

          # Resource requests / limits  (mirrors aws t3.nano, azure Standard_B1s)
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

          # Liveness probe — restart the pod if Tomcat's port goes dark.
          # NOTE: tomcat:10-jre17 ships with empty webapps/, so GET / → 404.
          # Use tcp_socket instead of http_get to avoid false probe failures.
          liveness_probe {
            tcp_socket {
              port = var.container_port
            }
            initial_delay_seconds = 30
            period_seconds        = 10
            timeout_seconds       = 5
            failure_threshold     = 3
          }

          # Readiness probe — hold traffic until Tomcat's port is accepting connections.
          readiness_probe {
            tcp_socket {
              port = var.container_port
            }
            initial_delay_seconds = 15
            period_seconds        = 5
            timeout_seconds       = 3
            success_threshold     = 1
          }
        }
      }
    }
  }

  timeouts {
    create = "10m"   # allow time for image pull + JVM startup on slow networks
    update = "10m"
    delete = "5m"
  }
}

# ---------------------------------------------------------------------------
# Service — exposes the Deployment via NodePort
# ---------------------------------------------------------------------------
resource "kubernetes_service_v1" "webapp" {
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
      name        = "http"
      port        = 80
      target_port = var.container_port
      node_port   = var.node_port
      protocol    = "TCP"
    }

    type = "NodePort"
  }
}

# ---------------------------------------------------------------------------
# HorizontalPodAutoscaler — scale Tomcat pods based on CPU utilisation
# ---------------------------------------------------------------------------
resource "kubernetes_horizontal_pod_autoscaler_v2" "webapp" {
  metadata {
    name      = "${var.app_name}-hpa"
    namespace = var.namespace
    labels = {
      app        = var.app_name
      managed-by = "terraform"
    }
  }

  spec {
    min_replicas = var.replicas
    max_replicas = var.hpa_max_replicas

    scale_target_ref {
      api_version = "apps/v1"
      kind        = "Deployment"
      name        = kubernetes_deployment_v1.webapp.metadata[0].name
    }

    metric {
      type = "Resource"
      resource {
        name = "cpu"
        target {
          type                = "Utilization"
          average_utilization = var.hpa_cpu_target
        }
      }
    }
  }
}
