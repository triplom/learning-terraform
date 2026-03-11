variable "environment" {
  description = "Environment name label applied to all Docker resources"
  type        = string
  default     = "local"
}

# ---------------------------------------------------------------------------
# Tomcat (Web Server)
# ---------------------------------------------------------------------------
variable "tomcat_image" {
  description = "Docker image for the Tomcat web server (equivalent to AWS Bitnami AMI / Azure cloud-init)"
  type        = string
  default     = "tomcat:10-jre17"
}

variable "tomcat_port" {
  description = "Host port to expose Tomcat on (maps to container port 8080)"
  type        = number
  default     = 8888
}

# ---------------------------------------------------------------------------
# MinIO (S3-compatible local object storage)
# Equivalent to: aws_s3_bucket / azurerm_storage_account
# ---------------------------------------------------------------------------
variable "minio_image" {
  description = "Docker image for the MinIO S3-compatible storage server"
  type        = string
  default     = "minio/minio:latest"
}

variable "minio_mc_image" {
  description = "Docker image for the MinIO Client (mc) used to create buckets"
  type        = string
  default     = "minio/mc:latest"
}

variable "minio_port" {
  description = "Host port to expose the MinIO S3 API on"
  type        = number
  default     = 9000
}

variable "minio_console_port" {
  description = "Host port to expose the MinIO web console on"
  type        = number
  default     = 9001
}

variable "minio_root_user" {
  description = "MinIO root username (equivalent to AWS Access Key ID)"
  type        = string
  default     = "minioadmin"
}

variable "minio_root_password" {
  description = "MinIO root password (equivalent to AWS Secret Access Key)"
  type        = string
  sensitive   = true
  default     = "minioadmin"
}

variable "minio_bucket_name" {
  description = "Name of the bucket to initialise inside MinIO (equivalent to aws_s3_bucket / azurerm_storage_container)"
  type        = string
  default     = "app-bucket"
}
