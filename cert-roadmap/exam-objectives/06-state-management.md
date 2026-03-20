# Objective 6: Navigate Terraform State

**Exam Weight:** ~15%
**Official Reference:** https://developer.hashicorp.com/terraform/tutorials/certification-004/associate-review-004

---

## 6.1 State Overview

Terraform state (`terraform.tfstate`) maps your configuration to real-world infrastructure. It is the foundation of how Terraform tracks what it manages.

### What State Stores
```json
{
  "version": 4,
  "terraform_version": "1.12.0",
  "serial": 12,
  "lineage": "abc-123-def-456",
  "outputs": {
    "instance_ip": { "value": "54.1.2.3", "type": "string" }
  },
  "resources": [
    {
      "mode": "managed",
      "type": "aws_instance",
      "name": "web",
      "provider": "provider[\"registry.terraform.io/hashicorp/aws\"]",
      "instances": [
        {
          "schema_version": 1,
          "attributes": {
            "id": "i-0123456789abcdef0",
            "ami": "ami-0c55b159cbfafe1f0",
            "instance_type": "t3.micro",
            ...
          }
        }
      ]
    }
  ]
}
```

### State File Fields
| Field | Description |
|-------|-------------|
| `version` | State file format version |
| `terraform_version` | Terraform CLI version that last modified state |
| `serial` | Increments on every state change (used for locking/conflict detection) |
| `lineage` | UUID assigned at state creation — uniquely identifies this state |
| `resources` | Array of all managed resources |

---

## 6.2 Backends

A **backend** defines where Terraform stores its state file and how operations are performed.

### Backend Types

#### Local Backend (default)
```hcl
terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}
```
- State stored on local filesystem
- No locking support
- Fine for single developer / learning

#### Remote Backends

**AWS S3 + DynamoDB**
```hcl
terraform {
  backend "s3" {
    bucket         = "my-terraform-state"
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-lock"  # For locking
    encrypt        = true
  }
}
```

**Azure Blob Storage**
```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "tfstatestorage"
    container_name       = "tfstate"
    key                  = "prod.terraform.tfstate"
  }
}
```

**GCS (Google Cloud Storage)**
```hcl
terraform {
  backend "gcs" {
    bucket = "my-tf-state-bucket"
    prefix = "terraform/state"
  }
}
```

**HCP Terraform**
```hcl
terraform {
  cloud {
    organization = "my-org"
    workspaces {
      name = "prod-network"
    }
  }
}
```

### Backend Feature Comparison
| Backend | Locking | Encryption | Versioning |
|---------|---------|------------|-----------|
| Local | No | No | No |
| S3 + DynamoDB | Yes | Optional | S3 versioning |
| Azure Blob | Yes | Yes | Yes |
| GCS | Yes | Yes | Yes |
| HCP Terraform | Yes | Yes | Yes |

---

## 6.3 State Locking

State locking prevents multiple operations from running concurrently and corrupting state.

### How Locking Works
1. Before modifying state, Terraform acquires a lock
2. If another operation holds the lock, Terraform waits or errors
3. After the operation completes, the lock is released

### Lock Error
```
Error: Error acquiring the state lock

Error message: ConditionalCheckFailedException: The conditional request failed
Lock Info:
  ID:        abc-123
  Path:      s3://bucket/terraform.tfstate
  Operation: OperationTypeApply
  Who:       user@hostname
  Version:   1.12.0
  Created:   2026-01-01 12:00:00
```

### Force-Unlock (use with caution!)
```bash
terraform force-unlock LOCK_ID
```
- Use ONLY when you're sure no other operation is running
- Incorrect use can corrupt state
- Requires the lock ID from the error message

---

## 6.4 State Drift

**Drift** occurs when real-world infrastructure diverges from the state file (e.g., someone manually deleted or modified a resource outside of Terraform).

### Detecting Drift
```bash
# Refresh state and show plan (no infra changes made)
terraform apply -refresh-only

# Or just run plan (always refreshes by default)
terraform plan
```

### Handling Drift
| Scenario | Action |
|----------|--------|
| Resource deleted outside Terraform | `terraform apply` will recreate it |
| Resource modified outside Terraform | `terraform apply` will revert it |
| Want to keep the drift | Add `ignore_changes` in lifecycle |
| Want Terraform to adopt the drift | `terraform apply -refresh-only` then update config |

### `moved` Block (Terraform 1.1+)
Rename a resource in config without destroying and recreating it:
```hcl
moved {
  from = aws_instance.old_name
  to   = aws_instance.new_name
}
```
- Terraform updates the state to reflect the new address
- No infrastructure changes (no destroy/create)
- Remove the `moved` block after the first apply

### `removed` Block (Terraform 1.7+)
Remove a resource from state without destroying it:
```hcl
removed {
  from = aws_instance.old_web
  lifecycle {
    destroy = false  # Keep the real resource, just remove from state
  }
}
```

---

## 6.5 Workspaces

Workspaces allow multiple state files within the same configuration directory — useful for managing dev/staging/prod from one codebase.

```bash
terraform workspace list             # List all workspaces
terraform workspace show             # Show current workspace
terraform workspace new staging      # Create and switch to new workspace
terraform workspace select staging   # Switch to existing workspace
terraform workspace delete staging   # Delete workspace (must be empty)
```

### Workspace in Configuration
```hcl
resource "aws_instance" "web" {
  instance_type = terraform.workspace == "prod" ? "t3.large" : "t3.micro"
  tags = {
    Environment = terraform.workspace
  }
}
```

### State Files by Workspace
```
terraform.tfstate           # default workspace
terraform.tfstate.d/
  staging/
    terraform.tfstate       # staging workspace
  prod/
    terraform.tfstate       # prod workspace
```

### Workspace Limitations
| | Local Workspaces | HCP Terraform Workspaces |
|--|----------------|------------------------|
| State isolation | Yes | Yes |
| Variable isolation | No (same tfvars) | Yes (per-workspace variables) |
| Team access control | No | Yes (RBAC) |
| Recommended for teams | No | Yes |

> **Exam tip:** Local workspaces are NOT recommended for production multi-environment management. Use separate configurations or HCP Terraform workspaces for proper isolation.

---

## 6.6 Remote State Data Source

Access outputs from another Terraform configuration's state:

```hcl
# In consuming config
data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "my-terraform-state"
    key    = "networking/terraform.tfstate"
    region = "us-east-1"
  }
}

# Use outputs from remote state
resource "aws_instance" "web" {
  subnet_id = data.terraform_remote_state.vpc.outputs.subnet_id
}
```

> **Exam tip:** `terraform_remote_state` only exposes **output values** from the remote state — not individual resource attributes directly. The remote config must define `output` blocks for any values you want to share.

---

## Practice Questions

**Q1:** What is the purpose of the `serial` field in the Terraform state file?
- A) It is the unique ID of the state file
- **B) It increments on every state change and is used to detect concurrent modifications** ✓
- C) It tracks the number of resources in state
- D) It is the Terraform version number

**Q2:** You run `terraform apply` and see: "Error acquiring the state lock." What does this mean?
- A) The state file is corrupted
- B) You don't have permission to write to the backend
- **C) Another Terraform operation is currently running and holds the lock** ✓
- D) The backend is unavailable

**Q3:** Which AWS services are commonly used together to provide remote state with locking?
- A) S3 + SNS
- **B) S3 + DynamoDB** ✓
- C) S3 + SQS
- D) EFS + DynamoDB

**Q4:** You renamed `aws_instance.web` to `aws_instance.webserver` in your config. Without a `moved` block, what will Terraform do?
- A) Update the resource in-place to use the new name
- **B) Destroy `aws_instance.web` and create a new `aws_instance.webserver`** ✓
- C) Warn about the rename but make no changes
- D) Error and refuse to plan

**Q5:** You want to share VPC subnet IDs from a networking Terraform config with an application Terraform config. What is the correct approach?
- A) Copy the state file to the application directory
- **B) Use `terraform_remote_state` data source to read outputs from the networking config's state** ✓
- C) Hardcode the subnet IDs in the application config
- D) Use `terraform import` to import the subnet into the application state

**Q6:** Which of the following is TRUE about Terraform workspaces?
- A) Each workspace uses a completely separate configuration directory
- B) Workspaces cannot use the same provider credentials
- **C) Each workspace has its own separate state file** ✓
- D) Workspaces require a remote backend to function

---

## Lab Reference

**Explore state in this repo:**
```bash
# From /home/triplom/terraform-cert-work/local/
cat terraform.tfstate              # Inspect state file structure
terraform show                     # Human-readable state view

# State commands (safe, read-only)
terraform state list               # List all resources in state
terraform state show docker_container.tomcat  # Show specific resource

# Workspace exploration
terraform workspace list           # Show workspaces (likely just 'default')
terraform workspace show

# Test refresh-only
terraform apply -refresh-only      # Detect drift without making changes
```

---

*Previous: [Objective 5 — Modules](./05-modules.md)*
*Next: [Objective 7 — Maintain Infrastructure](./07-maintain-infrastructure.md)*
