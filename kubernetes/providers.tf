terraform {
  required_version = ">= 1.3.0"

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 3.0"
    }
  }
}

# ---------------------------------------------------------------------------
# Kubernetes provider
#
# Authentication order (first match wins):
#   1. kubeconfig file  — local clusters (kind, minikube, docker-desktop)
#   2. In-cluster config — when Terraform itself runs inside a Pod
#
# Set kubeconfig_context to the target context name, e.g.:
#   kind-terraform-learn | minikube | docker-desktop | <aks-cluster> | <eks-cluster>
#
# Leave kubeconfig_context empty to use the currently active context.
# ---------------------------------------------------------------------------
provider "kubernetes" {
  config_path    = var.kubeconfig_path
  config_context = var.kubeconfig_context != "" ? var.kubeconfig_context : null
}
