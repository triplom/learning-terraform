output "deployment_name" {
  description = "Name of the MinIO Deployment"
  value       = kubernetes_deployment_v1.minio.metadata[0].name
}

output "service_name" {
  description = "Name of the MinIO NodePort Service"
  value       = kubernetes_service_v1.minio.metadata[0].name
}

output "s3_node_port" {
  description = "NodePort for the S3-compatible API endpoint"
  value       = var.s3_node_port
}

output "console_node_port" {
  description = "NodePort for the MinIO web console"
  value       = var.console_node_port
}

output "secret_name" {
  description = "Name of the Kubernetes Secret holding MinIO credentials"
  value       = kubernetes_secret_v1.minio.metadata[0].name
}

output "pvc_name" {
  description = "Name of the PersistentVolumeClaim used by MinIO"
  value       = kubernetes_persistent_volume_claim_v1.minio.metadata[0].name
}

output "config_map_name" {
  description = "Name of the MinIO ConfigMap"
  value       = kubernetes_config_map_v1.minio.metadata[0].name
}
