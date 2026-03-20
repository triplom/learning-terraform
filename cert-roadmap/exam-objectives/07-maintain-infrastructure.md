# Objective 7: Implement and Maintain State

**Exam Weight:** ~15%
**Official Reference:** https://developer.hashicorp.com/terraform/tutorials/certification-004/associate-review-004

---

## 7.1 `terraform import`

`terraform import` brings existing infrastructure under Terraform management by adding it to the state file without modifying the real resource.

### Classic Import (CLI-based)
```bash
# Syntax
terraform import <resource_type>.<resource_name> <provider_id>

# Examples
terraform import aws_instance.web i-0123456789abcdef0
terraform import aws_s3_bucket.logs my-existing-bucket-name
terraform import azurerm_resource_group.main /subscriptions/sub-id/resourceGroups/rg-name
terraform import docker_container.tomcat $(docker inspect -f '{{.Id}}' tomcat)
```

**Important:** Classic import only writes to state. You must still write the matching HCL config manually. Without a config block, the next `terraform plan` will propose to delete the imported resource.

### Generated Import Config (Terraform 1.5+)
```bash
terraform plan -generate-config-out=generated.tf
```
- Automatically generates HCL config for imported resources
- Still requires `import` block in config to trigger

### Import Block (Terraform 1.5+)
```hcl
import {
  to = aws_instance.web
  id = "i-0123456789abcdef0"
}
```
- Declarative import — no CLI import command needed
- Can be planned and applied like any other change
- Preview with `terraform plan` before applying
- Remove the `import` block after successful import

### Import Workflow (Modern)
```hcl
# 1. Add import block to config
import {
  to = aws_s3_bucket.existing
  id = "my-existing-bucket"
}

resource "aws_s3_bucket" "existing" {
  bucket = "my-existing-bucket"
  # ... other attributes
}
```
```bash
# 2. Preview
terraform plan

# 3. Apply
terraform apply

# 4. Remove the import block (it's no longer needed)
```

---

## 7.2 `terraform state` Commands

State manipulation commands — use carefully as mistakes can break Terraform's tracking.

### `terraform state list`
```bash
terraform state list                         # List all resources in state
terraform state list aws_instance.*          # Filter by type
terraform state list module.vpc.*            # List resources in a module
```

### `terraform state show`
```bash
terraform state show aws_instance.web        # Show all attributes of a resource
terraform state show module.vpc.aws_subnet.public
```
Output is in HCL-like format showing the current state attributes.

### `terraform state mv`
Move a resource in state — used for renaming without destroying.

```bash
# Rename a resource
terraform state mv aws_instance.web aws_instance.webserver

# Move into a module
terraform state mv aws_instance.web module.compute.aws_instance.web

# Move from one state file to another
terraform state mv -state-out=other.tfstate aws_instance.web aws_instance.web
```

> **Exam tip:** `terraform state mv` is the legacy alternative to the `moved` block. The `moved` block (Terraform 1.1+) is preferred as it's declarative and version-controlled.

### `terraform state rm`
Remove a resource from state WITHOUT destroying the real infrastructure.

```bash
terraform state rm aws_instance.web         # Remove from state (resource still exists)
terraform state rm module.vpc               # Remove entire module from state
```

**Use cases:**
- Resource will now be managed by another Terraform config
- You want to adopt an imported resource into a different state file
- Resource was deleted manually and you need to clean up state

> **Exam tip:** `terraform state rm` does NOT destroy the real resource. It only removes the reference from state. The resource will become "unmanaged" (orphaned in cloud).

### `terraform state pull` / `terraform state push`
```bash
terraform state pull > backup.tfstate       # Download remote state to stdout
terraform state push backup.tfstate         # Upload local state to remote backend
```
- `pull` reads state from backend
- `push` overwrites remote state (dangerous — use with caution)
- Used for manual backup/restore or state surgery

---

## 7.3 Verbose Logging

Control Terraform's log output level for debugging.

### Log Levels (`TF_LOG`)
```bash
export TF_LOG=TRACE    # Most verbose — shows all HTTP requests/responses
export TF_LOG=DEBUG    # Verbose
export TF_LOG=INFO     # Standard info messages
export TF_LOG=WARN     # Warnings only
export TF_LOG=ERROR    # Errors only
export TF_LOG=OFF      # Disable logging (default)
```

### Save Logs to File (`TF_LOG_PATH`)
```bash
export TF_LOG=DEBUG
export TF_LOG_PATH=/tmp/terraform-debug.log
terraform apply
```

### Provider Logs (`TF_LOG_PROVIDER`)
```bash
export TF_LOG_PROVIDER=DEBUG   # Debug only provider-level logs
```

### Useful for Debugging
- Provider API call failures
- Authentication issues
- State lock problems
- Network connectivity issues

---

## 7.4 State Maintenance Scenarios

### Scenario 1: Resource Renamed in Config
```bash
# Old way (state mv)
terraform state mv aws_instance.old aws_instance.new

# New way (moved block - preferred)
moved {
  from = aws_instance.old
  to   = aws_instance.new
}
```

### Scenario 2: Resource Deleted Outside Terraform
```bash
# 1. Detect: plan shows resource needs to be recreated
terraform plan

# 2a. Recreate: apply (Terraform creates it again)
terraform apply

# 2b. Remove from state: if you don't want Terraform to manage it
terraform state rm aws_instance.web
```

### Scenario 3: Import Existing Resource
```bash
# 1. Write the HCL config
# 2. Import
terraform import aws_instance.web i-0123456789abcdef0
# 3. Verify: plan should show no changes
terraform plan
```

### Scenario 4: Move Resource Between Configs
```bash
# Source config: remove from state
terraform state rm aws_instance.web

# Destination config: import into state
terraform import aws_instance.web i-0123456789abcdef0
```

### Scenario 5: State File Backup/Recovery
```bash
# Pull current state (backup)
terraform state pull > backup-$(date +%Y%m%d).tfstate

# If state is corrupted, restore
terraform state push backup-20260101.tfstate
```

---

## 7.5 `terraform taint` and `terraform untaint` (Deprecated)

```bash
# Mark resource for forced recreation (DEPRECATED in 1.x)
terraform taint aws_instance.web

# Remove taint
terraform untaint aws_instance.web
```

**Modern replacement:**
```bash
terraform apply -replace=aws_instance.web
# or in plan:
terraform plan -replace=aws_instance.web
```

> **Exam tip:** `terraform taint` is deprecated. The exam may reference it, but the recommended approach is `terraform apply -replace=<resource>`.

---

## Practice Questions

**Q1:** You have an existing S3 bucket that was created manually. You want to bring it under Terraform management. What is the correct sequence?
- A) Write HCL config → `terraform apply`
- **B) Write HCL config → `terraform import` → `terraform plan` (verify no changes)** ✓
- C) `terraform import` → write HCL config → `terraform apply`
- D) Run `terraform apply` with `-import` flag

**Q2:** What does `terraform state rm aws_instance.web` do?
- A) Destroys the AWS instance and removes it from state
- B) Marks the instance for replacement on next apply
- **C) Removes the resource from state without affecting the real infrastructure** ✓
- D) Forces Terraform to refresh the resource's state

**Q3:** You want to capture all Terraform debug output including provider API calls. Which environment variable setting is correct?
- A) `TF_LOG=VERBOSE`
- **B) `TF_LOG=TRACE`** ✓
- C) `TF_LOG=DEBUG`
- D) `TF_DEBUG=true`

**Q4:** A resource was renamed in the HCL config from `aws_instance.app` to `aws_instance.application`. Without intervention, what will `terraform plan` show?
- A) No changes — Terraform detects the rename automatically
- **B) Destroy `aws_instance.app` and create `aws_instance.application`** ✓
- C) An error about duplicate resource names
- D) Update the resource name tag in-place

**Q5:** What is the modern (Terraform 1.x) replacement for `terraform taint`?
- A) `terraform apply -force-replace`
- **B) `terraform apply -replace=<resource_address>`** ✓
- C) `terraform plan -recreate=<resource_address>`
- D) `terraform refresh -replace`

**Q6:** Which command would you use to view the current state attributes of a specific resource without running a plan?
- A) `terraform show -resource aws_instance.web`
- **B) `terraform state show aws_instance.web`** ✓
- C) `terraform inspect aws_instance.web`
- D) `terraform output aws_instance.web`

---

## Lab Reference

**Practice state commands in `/home/triplom/terraform-cert-work/local/`:**

```bash
# (Ensure a prior apply has been done)
terraform state list                     # List managed resources
terraform state show docker_container.tomcat  # Inspect a resource
terraform state pull                     # View raw state JSON

# Import practice (example with docker)
# 1. Manually create a container:
docker run -d --name test-import nginx

# 2. Write minimal HCL:
cat >> /tmp/import_test.tf <<'EOF'
resource "docker_container" "imported" {
  name  = "test-import"
  image = "nginx"
}
EOF

# 3. Import (from the local/ directory):
terraform import docker_container.imported $(docker inspect -f '{{.Id}}' test-import)

# 4. Verify
terraform state show docker_container.imported
terraform state list

# Enable debug logging
export TF_LOG=DEBUG
export TF_LOG_PATH=/tmp/tf-debug.log
terraform plan
export TF_LOG=OFF
cat /tmp/tf-debug.log | head -50
```

---

*Previous: [Objective 6 — State Management](./06-state-management.md)*
*Next: [Objective 8 — HCP Terraform](./08-hcp-terraform.md)*
