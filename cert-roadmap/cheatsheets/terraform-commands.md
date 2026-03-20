# Terraform Commands Cheatsheet

Quick reference for the HashiCorp Certified Terraform Associate (004) exam.

---

## Core Workflow Commands

```bash
terraform init                          # Initialize working directory
terraform init -upgrade                 # Upgrade providers to latest allowed
terraform init -reconfigure             # Reconfigure backend (don't migrate state)
terraform init -migrate-state           # Migrate state to new backend
terraform init -backend=false           # Skip backend init

terraform fmt                           # Format .tf files in current directory
terraform fmt -recursive                # Format including subdirectories
terraform fmt -check                    # Check only (exit 1 if changes needed)
terraform fmt -diff                     # Show formatting diff

terraform validate                      # Check syntax and config consistency
terraform validate -json                # JSON output (for CI/CD)

terraform plan                          # Show execution plan
terraform plan -out=tfplan              # Save plan to file
terraform plan -destroy                 # Preview destroy
terraform plan -var="key=value"         # Pass variable inline
terraform plan -var-file="prod.tfvars"  # Load variable file
terraform plan -target=aws_instance.web # Scope to specific resource
terraform plan -refresh=false           # Skip state refresh
terraform plan -replace=aws_instance.web # Mark resource for replacement
terraform plan -generate-config-out=gen.tf # Generate HCL for import blocks

terraform apply                         # Apply (prompts for approval)
terraform apply -auto-approve           # Apply without prompt (CI/CD)
terraform apply tfplan                  # Apply a saved plan file
terraform apply -var="key=value"        # Pass variable inline
terraform apply -var-file="vars.tfvars" # Load variable file
terraform apply -target=aws_instance.web # Apply to specific resource only
terraform apply -replace=aws_instance.web # Force replacement
terraform apply -refresh-only           # Sync state with real world (no infra changes)
terraform apply -destroy                # Destroy all (same as terraform destroy)

terraform destroy                       # Destroy all managed resources
terraform destroy -auto-approve         # Destroy without prompt
```

---

## State Commands

```bash
terraform show                          # Show current state (human-readable)
terraform show tfplan                   # Show contents of a saved plan
terraform show -json                    # JSON output

terraform state list                    # List all resources in state
terraform state list aws_instance.*     # Filter by glob pattern
terraform state list module.vpc.*       # List resources in a module

terraform state show aws_instance.web   # Show attributes of a resource
terraform state show module.vpc.aws_subnet.main

terraform state mv aws_instance.old aws_instance.new  # Rename in state
terraform state mv aws_instance.web module.compute.aws_instance.web  # Move to module
terraform state mv -state-out=other.tfstate aws_instance.web aws_instance.web

terraform state rm aws_instance.web     # Remove from state (resource NOT destroyed)
terraform state rm module.vpc           # Remove entire module from state

terraform state pull                    # Download remote state to stdout
terraform state pull > backup.tfstate   # Save state locally
terraform state push backup.tfstate     # Upload local state to backend (dangerous)

terraform force-unlock LOCK_ID          # Release a stuck state lock
```

---

## Import Commands

```bash
terraform import aws_instance.web i-0123456789abcdef0    # Import EC2 instance
terraform import aws_s3_bucket.logs my-bucket-name        # Import S3 bucket
terraform import docker_container.app $(docker inspect -f '{{.Id}}' app_name)
```

---

## Output Commands

```bash
terraform output                        # Show all outputs
terraform output instance_ip            # Show specific output
terraform output -json                  # JSON format
terraform output -raw instance_ip       # Raw string (no quotes, no newline)
```

---

## Workspace Commands

```bash
terraform workspace list                # List all workspaces
terraform workspace show                # Show current workspace
terraform workspace new staging         # Create and switch to new workspace
terraform workspace select prod         # Switch to existing workspace
terraform workspace delete staging      # Delete workspace
```

---

## Debugging & Inspection Commands

```bash
terraform version                       # Show Terraform and provider versions
terraform providers                     # List providers used in config
terraform graph                         # Output DOT-format dependency graph
terraform graph | dot -Tpng > graph.png # Visualize as image

terraform console                       # Interactive expression evaluator
# Inside console:
# > upper("hello")
# > length(["a","b","c"])
# > aws_instance.web.id  (if state exists)
```

---

## Environment Variables

```bash
# Logging
export TF_LOG=TRACE          # TRACE|DEBUG|INFO|WARN|ERROR|OFF
export TF_LOG_PROVIDER=DEBUG # Provider-specific logging
export TF_LOG_PATH=/tmp/tf.log  # Save logs to file

# Variables
export TF_VAR_region=us-east-1    # Sets var.region
export TF_VAR_instance_type=t3.micro

# HCP Terraform
export TF_TOKEN_app_terraform_io=<token>  # Auth without terraform login

# Parallelism
export TF_CLI_ARGS_plan="-parallelism=20"

# Input suppression
export TF_INPUT=false        # Disable interactive input prompts

# Workspace
export TF_WORKSPACE=staging  # Set default workspace
```

---

## Plan Output Symbols

| Symbol | Meaning |
|--------|---------|
| `+` | Resource will be **created** |
| `-` | Resource will be **destroyed** |
| `~` | Resource will be **updated** in-place |
| `-/+` | Resource will be **destroyed and recreated** |
| `+/-` | Resource will be **created then destroyed** (with `create_before_destroy`) |
| `<=` | Data source will be **read** |
| `->` | Value will change (shows old -> new) |
| `(known after apply)` | Value computed at apply time |

---

## Command Quick Reference Card

| Goal | Command |
|------|---------|
| Initialize new project | `terraform init` |
| Check formatting | `terraform fmt -check` |
| Validate config | `terraform validate` |
| Preview changes | `terraform plan` |
| Apply changes | `terraform apply` |
| Apply without prompt | `terraform apply -auto-approve` |
| Destroy all | `terraform destroy` |
| Save plan | `terraform plan -out=plan.out` |
| Apply saved plan | `terraform apply plan.out` |
| Force replace | `terraform apply -replace=res.name` |
| Sync state (no changes) | `terraform apply -refresh-only` |
| List state | `terraform state list` |
| Show resource in state | `terraform state show <addr>` |
| Remove from state | `terraform state rm <addr>` |
| Import resource | `terraform import <addr> <id>` |
| Upgrade providers | `terraform init -upgrade` |
| Enable debug logs | `export TF_LOG=DEBUG` |
| Open console | `terraform console` |
| Show outputs | `terraform output` |

---

*See also: [HCL Syntax Cheatsheet](./hcl-syntax.md) | [State Commands](./state-commands.md) | [Exam Tips](./exam-tips.md)*
