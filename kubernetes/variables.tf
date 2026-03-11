# ---------------------------------------------------------------------------
# Kubernetes provider authentication
# ---------------------------------------------------------------------------

variable "kubeconfig_path" {
  description = "Path to the kubeconfig file used by the Kubernetes provider"
  type        = string
  default     = "~/.kube/config"
}

variable "kubeconfig_context" {
  description = <<-EOT
    Kubernetes context to activate. Common values:
      kind-terraform-learn   (kind local cluster)
      minikube               (Minikube)
      docker-desktop         (Docker Desktop)
      <cluster-name>         (any cloud-provisioned cluster)
    Leave empty to use the current context from kubeconfig.
  EOT
  type        = string
  default     = ""
}

# ---------------------------------------------------------------------------
# General
# ---------------------------------------------------------------------------

variable "environment" {
  description = "Deployment environment label (dev | staging | prod)"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be one of: dev, staging, prod."
  }
}

variable "app_namespace" {
  description = "Kubernetes namespace that will contain all application resources"
  type        = string
  default     = "learning-terraform"
}

# ---------------------------------------------------------------------------
# Web app (Tomcat) — mirrors aws_instance / azurerm_linux_virtual_machine
# ---------------------------------------------------------------------------

variable "webapp_image" {
  description = "OCI image for the Tomcat web application"
  type        = string
  default     = "tomcat:10-jre17"
}

variable "webapp_replicas" {
  description = "Initial number of Tomcat pod replicas"
  type        = number
  default     = 1   # 1 is safer for local kind/minikube clusters; increase for staging/prod
}

variable "webapp_node_port" {
  description = "NodePort for the Tomcat service (30000–32767, avoids :8080 kubectl conflict)"
  type        = number
  default     = 30080
}

variable "webapp_hpa_max_replicas" {
  description = "Upper replica limit for the HorizontalPodAutoscaler"
  type        = number
  default     = 3   # modest cap for local clusters; raise for production
}

# ---------------------------------------------------------------------------
# Object storage (MinIO) — mirrors aws_s3_bucket / azurerm_storage_account
# ---------------------------------------------------------------------------

variable "minio_root_user" {
  description = "MinIO root access key (equivalent to AWS_ACCESS_KEY_ID)"
  type        = string
  default     = "minioadmin"
}

variable "minio_root_password" {
  description = "MinIO root secret key — override with a strong value in terraform.tfvars"
  type        = string
  sensitive   = true
  default     = "minioadmin"
}

variable "minio_storage_size" {
  description = "PVC storage size for MinIO data (e.g. 5Gi, 20Gi)"
  type        = string
  default     = "5Gi"
}

variable "minio_bucket_name" {
  description = "Name of the default bucket created inside MinIO"
  type        = string
  default     = "app-bucket"
}

variable "minio_s3_node_port" {
  description = "NodePort for the MinIO S3-compatible API (30000–32767)"
  type        = number
  default     = 30900
}

variable "minio_console_node_port" {
  description = "NodePort for the MinIO web console (30000–32767)"
  type        = number
  default     = 30901
}
