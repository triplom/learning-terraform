terraform terraform { required_providers { aws = { source  = "hashicorp/aws" version = "~> 5.0" } } }
provider "aws" { region = "us-east-1" }
locals { environment = "dev" project     = "demo-modulos"
tags = { Environment = local.environment Project     = local.project ManagedBy   = "Terraform" } }
module "vpc" { source = "./modules/vpc"
vpc_name       = "${local.project}-vpc" vpc_cidr       = "10.0.0.0/16" public_subnets  = ["10.0.2.0/24", "10.0.2.0/24"] private_subnets = ["10.0.3.0/24", "10.0.4.0/24"]
tags = local.tags }
module "logs_bucket" { source = "./modules/s3"
bucket_name        = "${local.project}-logs-${random_string.suffix.result}" versioning_enabled = true
tags = merge( local.tags, { Type = "Logs" } ) }
module "data_bucket" { source = "./modules/s3"
bucket_name        = "${local.project}-data-${random_string.suffix.result}" versioning_enabled = false
tags = merge( local.tags, { Type = "Data" } ) }
resource "random_string" "suffix" { length  = 8 special = false upper   = false } 