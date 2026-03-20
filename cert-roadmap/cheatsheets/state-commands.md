# State Commands Cheatsheet

Deep-dive reference for Terraform state management commands and patterns.

---

## State Inspection (Read-Only)

```bash
# List all resources in state
terraform state list

# Filter by resource type
terraform state list aws_instance.*
terraform state list aws_s3_bucket.*

# Filter by module
terraform state list module.vpc.*
terraform state list module.compute.*

# Show current state (human-readable HCL format)
terraform show

# Show specific resource attributes
terraform state show aws_instance.web
terraform state show module.vpc.aws_subnet.public
terraform state show 'aws_instance.web[0]'       # count instance
terraform state show 'aws_instance.web["app"]'   # for_each instance

# Show raw state JSON
terraform show -json
terraform state pull

# Show saved plan file
terraform show tfplan
terraform show -json tfplan
```

---

## State Modification (Use with Caution)

### Rename / Move
```bash
# Rename a resource
terraform state mv aws_instance.old aws_instance.new

# Move resource into a module
terraform state mv aws_instance.web module.compute.aws_instance.web

# Move resource out of a module
terraform state mv module.compute.aws_instance.web aws_instance.web

# Move between workspaces / state files
terraform state mv \
  -state=source.tfstate \
  -state-out=dest.tfstate \
  aws_instance.web aws_instance.web
```

### Remove from State (Resource NOT Destroyed)
```bash
# Remove single resource
terraform state rm aws_instance.web

# Remove all instances of a count resource
terraform state rm 'aws_instance.web[0]'
terraform state rm 'aws_instance.web[1]'

# Remove entire module
terraform state rm module.vpc

# Remove a for_each resource
terraform state rm 'aws_instance.web["app"]'
```

### State Backup & Restore
```bash
# Download current state
terraform state pull > backup-$(date +%Y%m%d-%H%M%S).tfstate

# Restore state (overwrites remote — dangerous!)
terraform state push backup-20260101.tfstate

# Push with force (ignore lineage mismatch — very dangerous!)
terraform state push -force backup.tfstate
```

### Force-Unlock a Stuck Lock
```bash
# Get lock ID from error message, then:
terraform force-unlock LOCK_ID_HERE

# Example:
terraform force-unlock abc-123-def-456
```
> Only use when you are certain no other Terraform operation is running.

---

## Import Commands

### Classic Import (CLI)
```bash
# Syntax
terraform import <resource_address> <provider_id>

# AWS Examples
terraform import aws_instance.web i-0123456789abcdef0
terraform import aws_s3_bucket.logs my-bucket-name
terraform import aws_vpc.main vpc-12345678
terraform import aws_subnet.public subnet-12345678
terraform import aws_security_group.web sg-12345678
terraform import aws_iam_role.app arn:aws:iam::123456789012:role/my-role
terraform import aws_iam_policy.app arn:aws:iam::123456789012:policy/my-policy

# Azure Examples
terraform import azurerm_resource_group.rg \
  /subscriptions/<sub-id>/resourceGroups/my-rg
terraform import azurerm_virtual_network.vnet \
  /subscriptions/<sub-id>/resourceGroups/my-rg/providers/Microsoft.Network/virtualNetworks/my-vnet

# Docker Examples
terraform import docker_container.web $(docker inspect -f '{{.Id}}' web)
terraform import docker_image.nginx sha256:abc123...

# Module resource import
terraform import 'module.vpc.aws_subnet.public' subnet-12345678
```

### Modern Import (Declarative Block — Terraform 1.5+)
```hcl
# In your .tf config file
import {
  to = aws_instance.web
  id = "i-0123456789abcdef0"
}

# Then run:
# terraform plan (preview import)
# terraform apply (execute import)
# Remove import block after successful apply
```

### Generate Config from Import (Terraform 1.5+)
```bash
# Add import block, then generate HCL:
terraform plan -generate-config-out=generated.tf
# Review generated.tf, then apply
```

---

## Workspace Commands

```bash
# List workspaces (current marked with *)
terraform workspace list

# Show current workspace name
terraform workspace show

# Create and switch to new workspace
terraform workspace new staging

# Switch to existing workspace
terraform workspace select prod

# Delete workspace (must be empty or -force)
terraform workspace delete staging
terraform workspace delete -force staging
```

### Reference Workspace in Config
```hcl
# Current workspace name in config
locals {
  env = terraform.workspace
}

# Conditional based on workspace
resource "aws_instance" "web" {
  instance_type = terraform.workspace == "prod" ? "t3.large" : "t3.micro"
}
```

### Workspace State File Locations (Local Backend)
```
terraform.tfstate              # 'default' workspace
terraform.tfstate.d/
  staging/
    terraform.tfstate
  prod/
    terraform.tfstate
```

---

## Remote State Data Source

```hcl
# Read outputs from another config's state
data "terraform_remote_state" "networking" {
  backend = "s3"
  config = {
    bucket = "my-terraform-state"
    key    = "networking/terraform.tfstate"
    region = "us-east-1"
  }
}

# Access outputs
resource "aws_instance" "app" {
  subnet_id = data.terraform_remote_state.networking.outputs.private_subnet_id
  vpc_security_group_ids = [
    data.terraform_remote_state.networking.outputs.app_security_group_id
  ]
}
```

---

## Backend Configurations

### S3 + DynamoDB (AWS)
```hcl
terraform {
  backend "s3" {
    bucket         = "my-terraform-state"
    key            = "env/prod/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}
```

### Azure Blob Storage
```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "rg-terraform"
    storage_account_name = "tfstatestorage"
    container_name       = "tfstate"
    key                  = "prod.terraform.tfstate"
  }
}
```

### GCS (Google Cloud)
```hcl
terraform {
  backend "gcs" {
    bucket = "my-terraform-state-bucket"
    prefix = "terraform/state"
  }
}
```

### HCP Terraform (Cloud)
```hcl
terraform {
  cloud {
    organization = "my-org"
    workspaces {
      name = "prod-infra"
      # OR: tags = ["prod"]
    }
  }
}
```

### Local (Default)
```hcl
terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}
```

---

## State File Anatomy

```json
{
  "version": 4,                           // State format version
  "terraform_version": "1.12.0",          // Terraform version used
  "serial": 42,                           // Monotonically increasing counter
  "lineage": "uuid-...",                  // Unique identifier for this state
  "outputs": {
    "instance_ip": {
      "value": "54.1.2.3",
      "type": "string",
      "sensitive": false
    }
  },
  "resources": [
    {
      "mode": "managed",                  // "managed" or "data"
      "type": "aws_instance",
      "name": "web",
      "provider": "provider[\"...\"]",
      "instances": [
        {
          "schema_version": 1,
          "attributes": {
            "id": "i-0123456789abcdef0",
            "ami": "ami-0c55b159cbfafe1f0",
            "instance_type": "t3.micro",
            "tags": {"Name": "web"}
          },
          "private": "base64encodedprivatedata..."
        }
      ]
    }
  ]
}
```

---

## Moved Block vs State MV

| | `moved` block | `terraform state mv` |
|--|--------------|---------------------|
| Approach | Declarative (in config) | Imperative (CLI) |
| Version-controlled | Yes | No |
| Auditable | Yes (in git history) | No |
| Team-friendly | Yes | Requires coordination |
| Terraform version | 1.1+ | Any version |
| Recommendation | **Preferred** | Legacy |

---

## Common State Troubleshooting

| Problem | Command |
|---------|---------|
| State lock stuck | `terraform force-unlock <LOCK_ID>` |
| Resource renamed in config | Add `moved` block OR `terraform state mv` |
| Resource deleted outside TF | `terraform apply` (recreates) OR `terraform state rm` |
| Need to see what's in state | `terraform state list` + `terraform state show` |
| State file corrupted | Restore from backup via `terraform state push` |
| Need to move state to new backend | `terraform init -migrate-state` |
| Resource should be managed elsewhere | `terraform state rm` from current, then `terraform import` in other |

---

*See also: [Terraform Commands](./terraform-commands.md) | [HCL Syntax](./hcl-syntax.md) | [Exam Tips](./exam-tips.md)*
