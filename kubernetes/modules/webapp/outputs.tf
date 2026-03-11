output "deployment_name" {
  description = "Name of the Tomcat Deployment"
  value       = kubernetes_deployment_v1.webapp.metadata[0].name
}

output "service_name" {
  description = "Name of the webapp NodePort Service"
  value       = kubernetes_service_v1.webapp.metadata[0].name
}

output "node_port" {
  description = "NodePort the app is reachable on"
  value       = var.node_port
}

output "config_map_name" {
  description = "Name of the webapp ConfigMap"
  value       = kubernetes_config_map_v1.webapp.metadata[0].name
}

output "hpa_name" {
  description = "Name of the HorizontalPodAutoscaler"
  value       = kubernetes_horizontal_pod_autoscaler_v2.webapp.metadata[0].name
}
