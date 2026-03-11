variable "namespace" {
  description = "Kubernetes namespace to deploy MinIO into"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "app_name" {
  description = "Application name used as label and resource prefix"
  type        = string
  default     = "minio"
}

variable "image" {
  description = "MinIO container image"
  type        = string
  default     = "minio/minio:latest"
}

variable "minio_root_user" {
  description = "MinIO root access key (equivalent to AWS_ACCESS_KEY_ID)"
  type        = string
  default     = "minioadmin"
}

variable "minio_root_password" {
  description = "MinIO root secret key (equivalent to AWS_SECRET_ACCESS_KEY)"
  type        = string
  sensitive   = true
}

variable "storage_size" {
  description = "PersistentVolumeClaim size for MinIO data directory"
  type        = string
  default     = "5Gi"
}

variable "bucket_name" {
  description = "Default bucket name exposed via the MinIO console"
  type        = string
  default     = "app-bucket"
}

variable "s3_node_port" {
  description = "NodePort for the S3-compatible API (30000–32767)"
  type        = number
  default     = 30900
}

variable "console_node_port" {
  description = "NodePort for the MinIO web console (30000–32767)"
  type        = number
  default     = 30901
}

variable "cpu_request" {
  description = "CPU resource request"
  type        = string
  default     = "250m"
}

variable "memory_request" {
  description = "Memory resource request"
  type        = string
  default     = "256Mi"
}

variable "cpu_limit" {
  description = "CPU resource limit"
  type        = string
  default     = "500m"
}

variable "memory_limit" {
  description = "Memory resource limit"
  type        = string
  default     = "512Mi"
}
