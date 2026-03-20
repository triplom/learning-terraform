# Hands-On Labs

Practical labs using the existing code in this repository. All labs reference real Terraform configurations — no need to write Terraform from scratch.

---

## Prerequisites

```bash
# Verify Terraform is installed
terraform version

# Verify Docker is running (for local labs)
docker info

# Working directory
cd /home/triplom/terraform-cert-work
```

---

## Lab 1: Core Workflow (Objective 3)

**Time:** 30–45 minutes
**Directory:** `local/`
**Terraform version:** 1.x
**Cloud required:** No (uses Docker)

### Setup
```bash
cd /home/triplom/terraform-cert-work/local
```

### Steps

**1. Initialize**
```bash
terraform init
# Observe: provider download, lock file creation
cat .terraform.lock.hcl    # Inspect lock file
ls .terraform/providers/   # Provider binary location
```

**2. Format and Validate**
```bash
terraform fmt -check       # Check formatting (should pass)
terraform fmt -diff        # Preview any formatting changes
terraform validate         # Validate configuration
```

**3. Plan**
```bash
terraform plan             # Review proposed changes
# Observe: + symbols, resource types, attribute values
terraform plan -out=lab1.plan   # Save plan
terraform show lab1.plan        # Inspect saved plan
```

**4. Apply**
```bash
terraform apply lab1.plan       # Apply saved plan (no prompt)
# Observe: resource creation output, IDs assigned
```

**5. Inspect State**
```bash
terraform state list            # See managed resources
terraform state show docker_container.tomcat  # Inspect resource
terraform show                  # Full state view
terraform output                # View outputs (if defined)
```

**6. Refresh-Only**
```bash
terraform apply -refresh-only   # Detect any drift
# Should show: No changes (if no external modifications)
```

**7. Destroy**
```bash
terraform plan -destroy         # Preview destroy
terraform destroy -auto-approve # Destroy everything
terraform state list            # Should be empty
```

**Key concepts practiced:** init, fmt, validate, plan, apply, state inspection, refresh-only, destroy

---

## Lab 2: Variables and Outputs (Objective 4)

**Time:** 20–30 minutes
**Directory:** `local/` (or create a scratch workspace)

### Explore the existing variable setup
```bash
cd /home/triplom/terraform-cert-work/local
cat main.tf        # Observe variable references

# If variables.tf and outputs.tf exist, review them
ls *.tf
```

### Test variable precedence
```bash
# Default (from variable block)
terraform plan

# Override with -var flag
terraform plan -var="environment=staging"

# Override with environment variable (highest precedence)
export TF_VAR_environment=prod
terraform plan
unset TF_VAR_environment
```

### Use terraform console
```bash
terraform console
# Test expressions:
> upper("hello")
> length([1, 2, 3])
> format("web-%s-%02d", "app", 1)
> merge({a=1}, {b=2})
> [for i in range(3) : "server-${i}"]
> exit
```

**Key concepts practiced:** variable declaration, defaults, precedence, console for function testing

---

## Lab 3: State Management (Objectives 6 & 7)

**Time:** 30–45 minutes
**Directory:** `local/`

### Step 1: Apply infrastructure
```bash
cd /home/triplom/terraform-cert-work/local
terraform apply -auto-approve
```

### Step 2: Inspect state
```bash
terraform state list
terraform state show docker_container.tomcat    # Adjust to actual resource name
terraform state pull | python3 -m json.tool    # Pretty-print state JSON
```

### Step 3: Practice state mv (simulate rename)
```bash
# IMPORTANT: This is a destructive state operation — in this lab it's safe
# because we're using Docker, but understand the implications

# List resources first
terraform state list

# Move a resource (rename simulation)
# terraform state mv docker_container.tomcat docker_container.tomcat_app

# Check state after move
# terraform state list
# terraform plan   # Should show rename effect
```

### Step 4: Practice state rm
```bash
# Remove from state (resource will still exist as a Docker container)
terraform state rm docker_container.tomcat     # Adjust to actual name

# Verify: resource gone from state
terraform state list

# Verify: container still exists in Docker
docker ps

# Re-import it back
CONTAINER_ID=$(docker inspect -f '{{.Id}}' tomcat 2>/dev/null || docker ps -q --filter name=tomcat | head -1)
terraform import docker_container.tomcat "$CONTAINER_ID"

# Verify state is restored
terraform state list
terraform plan    # Should show no changes
```

### Step 5: Enable debug logging
```bash
export TF_LOG=DEBUG
export TF_LOG_PATH=/tmp/terraform-lab3.log
terraform plan
export TF_LOG=OFF

# Inspect log
wc -l /tmp/terraform-lab3.log
head -50 /tmp/terraform-lab3.log
```

**Key concepts practiced:** state list, state show, state mv, state rm, import, debug logging

---

## Lab 4: Modules (Objective 5)

**Time:** 20–30 minutes
**Directory:** `kubernetes/`

### Explore the module structure
```bash
cd /home/triplom/terraform-cert-work/kubernetes

# Root module files
ls *.tf

# Child modules
ls modules/
ls modules/webapp/
ls modules/storage/

# Understand the interface
cat modules/webapp/variables.tf    # Module inputs
cat modules/webapp/outputs.tf      # Module outputs
cat modules/webapp/main.tf         # Module resources

# See how root calls the modules
cat main.tf
```

### Inspect module sourcing
```bash
# View what modules are registered
# (After init)
terraform init
cat .terraform/modules/modules.json  # Module metadata
```

### Explore the public registry
- Browse https://registry.terraform.io/browse/modules
- Find `terraform-aws-modules/vpc/aws`
- Note: `source`, `version`, available inputs and outputs

**Key concepts practiced:** module structure, inputs/outputs, local module sourcing, init with modules

---

## Lab 5: Provider Versions and Lock File (Objective 2)

**Time:** 15–20 minutes
**Directory:** `local/`

```bash
cd /home/triplom/terraform-cert-work/local

# Examine provider requirements
cat main.tf | grep -A 10 "required_providers"

# Inspect the lock file
cat .terraform.lock.hcl

# Upgrade provider (if newer version available within constraint)
terraform init -upgrade

# Check if lock file changed
cat .terraform.lock.hcl

# View all providers in use
terraform providers

# View terraform and provider versions
terraform version
```

**Key concepts practiced:** version constraints, lock file, provider tiers, init -upgrade

---

## Lab 6: Workspace Commands (Objective 6)

**Time:** 15–20 minutes
**Directory:** `local/`

```bash
cd /home/triplom/terraform-cert-work/local

# Current workspace
terraform workspace show     # Should show "default"
terraform workspace list

# Create new workspace
terraform workspace new staging
terraform workspace show     # Now "staging"

# State is separate per workspace
terraform state list         # Empty in staging workspace

# Switch back
terraform workspace select default
terraform state list         # Resources visible again

# Delete staging (must be empty)
terraform workspace delete staging

# Reference workspace in console
terraform console
> terraform.workspace        # Shows current workspace name
> exit
```

**Key concepts practiced:** workspace create/select/delete, state isolation per workspace

---

## Lab 7: Import (Objective 7)

**Time:** 20–30 minutes
**Directory:** `local/`

### Create a resource outside Terraform
```bash
# Pull nginx image manually (outside Terraform)
docker pull nginx:latest

# Note the image ID
docker images nginx:latest --format "{{.ID}}"
```

### Import it into Terraform
```bash
cd /home/triplom/terraform-cert-work/local

# 1. Add HCL config for the image (in a scratch .tf file)
cat > /tmp/import_test.tf << 'EOF'
resource "docker_image" "nginx_imported" {
  name = "nginx:latest"
}
EOF
cp /tmp/import_test.tf ./nginx_import.tf

# 2. Get the image ID
IMAGE_ID=$(docker images nginx:latest --format "{{.ID}}")
echo "Image ID: $IMAGE_ID"

# 3. Import
terraform import docker_image.nginx_imported "$IMAGE_ID"

# 4. Verify no diff
terraform plan   # Should show no changes for the imported resource

# 5. Clean up
rm ./nginx_import.tf
terraform state rm docker_image.nginx_imported
```

**Key concepts practiced:** terraform import CLI syntax, post-import plan verification

---

## Lab Reference Summary

| Lab | Objectives | Time | Cloud Needed |
|-----|-----------|------|-------------|
| 1: Core Workflow | 3 | 30-45 min | No (Docker) |
| 2: Variables & Outputs | 4 | 20-30 min | No |
| 3: State Management | 6, 7 | 30-45 min | No (Docker) |
| 4: Modules | 5 | 20-30 min | No |
| 5: Provider Versions | 2 | 15-20 min | No |
| 6: Workspaces | 6 | 15-20 min | No |
| 7: Import | 7 | 20-30 min | No (Docker) |

**Total estimated time:** ~3.5–4 hours for all labs

---

## Lab Troubleshooting

| Issue | Solution |
|-------|---------|
| Docker not running | `sudo systemctl start docker` |
| Permission denied on Docker | `sudo usermod -aG docker $USER` then re-login |
| Provider not found | Run `terraform init` in the directory |
| State locked | `terraform force-unlock <LOCK_ID>` |
| Plan shows unexpected changes | Check if Docker containers still running |
| Import fails | Verify container/image ID is correct with `docker ps` or `docker images` |

---

*Back to: [Cert Roadmap Overview](../README.md) | [Study Plan](../study-plan/README.md)*
