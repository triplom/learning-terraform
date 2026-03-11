variable "namespace" {
  description = "Kubernetes namespace to deploy the webapp into"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "app_name" {
  description = "Application name used as label and resource prefix"
  type        = string
  default     = "webapp"
}

variable "image" {
  description = "Container image for the web application"
  type        = string
  default     = "tomcat:10-jre17"
}

variable "replicas" {
  description = "Number of desired pod replicas"
  type        = number
  default     = 2
}

variable "node_port" {
  description = "NodePort to expose the app on the host (30000–32767)"
  type        = number
  default     = 30080
}

variable "container_port" {
  description = "Port the container listens on internally"
  type        = number
  default     = 8080
}

variable "cpu_request" {
  description = "CPU resource request per pod"
  type        = string
  default     = "250m"
}

variable "memory_request" {
  description = "Memory resource request per pod"
  type        = string
  default     = "256Mi"
}

variable "cpu_limit" {
  description = "CPU resource limit per pod"
  type        = string
  default     = "500m"
}

variable "memory_limit" {
  description = "Memory resource limit per pod"
  type        = string
  default     = "512Mi"
}

variable "hpa_max_replicas" {
  description = "Maximum number of replicas for the HorizontalPodAutoscaler"
  type        = number
  default     = 6
}

variable "hpa_cpu_target" {
  description = "Target CPU utilisation percentage for HPA scaling"
  type        = number
  default     = 70
}
