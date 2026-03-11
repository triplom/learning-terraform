# ---------------------------------------------------------------------------
# Namespace
# ---------------------------------------------------------------------------

output "namespace" {
  description = "Kubernetes namespace that contains all application resources"
  value       = kubernetes_namespace_v1.app.metadata[0].name
}

# ---------------------------------------------------------------------------
# Web app (Tomcat)
# ---------------------------------------------------------------------------

output "webapp_url" {
  description = "URL to reach the Tomcat web application (via NodePort)"
  value       = "http://localhost:${var.webapp_node_port}"
}

output "webapp_deployment_name" {
  description = "Name of the Tomcat Kubernetes Deployment"
  value       = module.webapp.deployment_name
}

output "webapp_service_name" {
  description = "Name of the Tomcat NodePort Service"
  value       = module.webapp.service_name
}

output "webapp_node_port" {
  description = "NodePort the Tomcat service is bound to on the host"
  value       = module.webapp.node_port
}

output "webapp_hpa_name" {
  description = "Name of the HorizontalPodAutoscaler managing Tomcat pods"
  value       = module.webapp.hpa_name
}

# ---------------------------------------------------------------------------
# Object storage (MinIO)
# ---------------------------------------------------------------------------

output "minio_s3_url" {
  description = "S3-compatible API endpoint (AWS CLI, mc, boto3)"
  value       = "http://localhost:${module.storage.s3_node_port}"
}

output "minio_console_url" {
  description = "MinIO web console URL"
  value       = "http://localhost:${module.storage.console_node_port}"
}

output "minio_deployment_name" {
  description = "Name of the MinIO Kubernetes Deployment"
  value       = module.storage.deployment_name
}

output "minio_service_name" {
  description = "Name of the MinIO NodePort Service"
  value       = module.storage.service_name
}

output "minio_secret_name" {
  description = "Kubernetes Secret that holds MinIO credentials"
  value       = module.storage.secret_name
}

output "minio_pvc_name" {
  description = "PersistentVolumeClaim backing MinIO data storage"
  value       = module.storage.pvc_name
}

output "minio_access_key" {
  description = "MinIO root access key (username)"
  value       = var.minio_root_user
}

output "minio_secret_key" {
  description = "MinIO root secret key (password)"
  value       = var.minio_root_password
  sensitive   = true
}
