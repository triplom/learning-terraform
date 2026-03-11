# =============================================================================
# kubernetes/main.tf
#
# Root module — Deploys a full two-tier web application on Kubernetes:
#
#   Tier 1 (webapp module)  — Tomcat servlet container
#                             Deployment + NodePort Service + HPA + ConfigMap
#
#   Tier 2 (storage module) — MinIO S3-compatible object storage
#                             Deployment + NodePort Service + PVC + Secret + ConfigMap
#
# Kubernetes equivalent of:
#   aws/main.tf    → EC2 (Tomcat) + S3 Bucket
#   azure/main.tf  → Linux VM (Tomcat) + Storage Account
#   local/main.tf  → Docker Tomcat container + Docker MinIO container
# =============================================================================

# ---------------------------------------------------------------------------
# Namespace — isolates all app resources from the default namespace
# ---------------------------------------------------------------------------
resource "kubernetes_namespace_v1" "app" {
  metadata {
    name = var.app_namespace

    labels = {
      environment = var.environment
      project     = "learning-terraform"
      managed-by  = "terraform"
    }
  }
}

# ---------------------------------------------------------------------------
# Module: webapp
# Tomcat web server — ConfigMap, Deployment, NodePort Service, HPA
# Source: ./modules/webapp
# ---------------------------------------------------------------------------
module "webapp" {
  source = "./modules/webapp"

  namespace        = kubernetes_namespace_v1.app.metadata[0].name
  environment      = var.environment
  image            = var.webapp_image
  replicas         = var.webapp_replicas
  node_port        = var.webapp_node_port
  hpa_max_replicas = var.webapp_hpa_max_replicas
}

# ---------------------------------------------------------------------------
# Module: storage
# MinIO object storage — Secret, ConfigMap, PVC, Deployment, NodePort Service
# Source: ./modules/storage
# ---------------------------------------------------------------------------
module "storage" {
  source = "./modules/storage"

  namespace           = kubernetes_namespace_v1.app.metadata[0].name
  environment         = var.environment
  minio_root_user     = var.minio_root_user
  minio_root_password = var.minio_root_password
  storage_size        = var.minio_storage_size
  bucket_name         = var.minio_bucket_name
  s3_node_port        = var.minio_s3_node_port
  console_node_port   = var.minio_console_node_port
}
