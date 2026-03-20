# Objective 3: Understand Terraform Basics (Core Workflow)

**Exam Weight:** ~15%
**Official Reference:** https://developer.hashicorp.com/terraform/tutorials/certification-004/associate-review-004

---

## 3.1 The Core Workflow

```
Write → Init → Validate → Plan → Apply → Destroy
```

| Step | Command | Description |
|------|---------|-------------|
| Write | (editor) | Author `.tf` configuration files |
| Initialize | `terraform init` | Download providers/modules, set up backend |
| Format | `terraform fmt` | Auto-format code to canonical style |
| Validate | `terraform validate` | Check syntax and logic without contacting APIs |
| Plan | `terraform plan` | Show execution plan (what will change) |
| Apply | `terraform apply` | Execute the plan; create/update/delete resources |
| Destroy | `terraform destroy` | Destroy all managed resources |

---

## 3.2 `terraform init`

Initializes the working directory. **Must run before any other command.**

```bash
terraform init                    # Standard init
terraform init -upgrade           # Upgrade providers to latest allowed version
terraform init -backend=false     # Skip backend initialization
terraform init -reconfigure       # Reconfigure backend without migrating state
terraform init -migrate-state     # Migrate state to new backend
```

### What `init` Does
1. Downloads required **providers** into `.terraform/providers/`
2. Downloads required **modules** into `.terraform/modules/`
3. Initializes the configured **backend** (local or remote)
4. Creates/updates `.terraform.lock.hcl`

### When to Re-run `init`
- Added/changed a provider
- Added/changed a module source
- Changed the backend configuration
- First time in a new working directory

> **Exam tip:** `terraform init` does NOT read or modify `terraform.tfstate`. It only sets up the working directory.

---

## 3.3 `terraform fmt`

Formats Terraform code to the canonical style defined by HashiCorp.

```bash
terraform fmt             # Format files in current directory
terraform fmt -recursive  # Format files in subdirectories too
terraform fmt -check      # Check only (exit 1 if formatting needed, no changes)
terraform fmt -diff       # Show diff of what would change
```

### What `fmt` Fixes
- Indentation (2 spaces)
- Alignment of `=` signs in blocks
- Blank line consistency
- Quote style

> **Exam tip:** `terraform fmt` only formats — it does NOT validate logic. Use `terraform validate` for that.

---

## 3.4 `terraform validate`

Checks configuration for syntax errors and internal consistency.

```bash
terraform validate          # Validate current directory
terraform validate -json    # Output results as JSON (for CI/CD parsing)
```

### What `validate` Checks
- HCL syntax correctness
- Required arguments present
- Argument types match expected types
- References to undefined variables or resources
- Invalid resource type names

### What `validate` Does NOT Check
- Whether provider credentials are valid
- Whether referenced resources actually exist in the cloud
- Network connectivity to provider APIs

> **Exam tip:** `terraform validate` requires `terraform init` to have been run first (needs provider schemas to validate against).

---

## 3.5 `terraform plan`

Generates an execution plan showing what Terraform will do without making changes.

```bash
terraform plan                        # Show plan to stdout
terraform plan -out=tfplan            # Save plan to file
terraform plan -destroy               # Show destroy plan
terraform plan -var="key=value"       # Pass variable value
terraform plan -var-file="prod.tfvars" # Use variable file
terraform plan -target=resource.name  # Scope to specific resource
terraform plan -refresh=false         # Skip state refresh
```

### Plan Output Symbols
| Symbol | Meaning |
|--------|---------|
| `+` | Resource will be **created** |
| `-` | Resource will be **destroyed** |
| `~` | Resource will be **updated** in-place |
| `-/+` | Resource will be **destroyed and recreated** (replacement) |
| `<=` | Data source will be **read** |

### Plan Phases
1. **Refresh** — Query real-world state to detect drift (can be skipped with `-refresh=false`)
2. **Diff** — Compare refreshed state vs desired config
3. **Output** — Display planned changes

---

## 3.6 `terraform apply`

Executes the plan; creates, updates, or deletes resources.

```bash
terraform apply                      # Interactive: shows plan, prompts for approval
terraform apply -auto-approve        # Skip interactive approval (CI/CD)
terraform apply tfplan               # Apply a saved plan file
terraform apply -var="key=value"     # Pass variable
terraform apply -target=resource     # Apply only to specific resource
terraform apply -replace=resource    # Force replacement of a specific resource
```

### Apply Behavior
- Without a saved plan: generates a new plan and prompts for approval
- With a saved plan (`terraform apply tfplan`): applies exactly that plan, no prompt
- Updates `terraform.tfstate` after successful apply
- If apply fails mid-way, partial state is saved (resources created before failure are tracked)

> **Exam tip:** `terraform apply -auto-approve` bypasses the confirmation prompt — common in CI/CD but risky in production.

---

## 3.7 `terraform destroy`

Destroys all resources managed by the current configuration.

```bash
terraform destroy                    # Interactive destroy
terraform destroy -auto-approve      # Skip confirmation
terraform plan -destroy              # Preview what destroy will do
terraform apply -destroy             # Equivalent to terraform destroy
```

> **Exam tip:** `terraform destroy` is equivalent to `terraform apply -destroy`. Both commands do the same thing.

---

## 3.8 Additional Core Commands

### `terraform output`
```bash
terraform output                     # Show all outputs
terraform output instance_ip         # Show specific output value
terraform output -json               # JSON format (for scripting)
terraform output -raw instance_ip    # Raw string (no quotes)
```

### `terraform show`
```bash
terraform show                       # Show current state in human-readable form
terraform show terraform.tfstate     # Show a specific state file
terraform show tfplan                # Show contents of a saved plan
terraform show -json                 # JSON output
```

### `terraform refresh`
```bash
terraform refresh   # Update state file to match real-world (deprecated in 1.x)
# Preferred: terraform apply -refresh-only
terraform apply -refresh-only        # Sync state with real world (no infra changes)
```

> **Exam tip:** `terraform refresh` is deprecated. Use `terraform apply -refresh-only` instead. This is a known exam question topic.

### `terraform graph`
```bash
terraform graph | dot -Tpng > graph.png   # Visualize dependency graph
```

---

## 3.9 Exam-Focused Key Points

### 3a. Describe Terraform workflow
- Write → Init → Validate → Plan → Apply → Destroy
- `plan` is always safe (read-only); only `apply` and `destroy` make changes

### 3b. Initialize a Terraform working directory (`terraform init`)
- Downloads providers and modules
- Sets up backend
- Must run before plan/apply/validate

### 3c. Validate a Terraform configuration (`terraform validate`)
- Checks syntax and internal consistency
- Does NOT contact provider APIs
- Requires prior `init`

### 3d. Generate and review an execution plan (`terraform plan`)
- Shows `+`, `-`, `~`, `-/+` changes
- `-out` saves plan for later apply
- `-refresh=false` skips state refresh

### 3e. Execute changes to infrastructure (`terraform apply`)
- Creates/updates/deletes resources
- Updates state file
- `-auto-approve` skips confirmation

### 3f. Destroy Terraform managed infrastructure (`terraform destroy`)
- Removes all managed resources
- Equivalent to `terraform apply -destroy`

---

## Practice Questions

**Q1:** A developer runs `terraform plan` and sees `-/+` next to a resource. What does this mean?
- A) The resource will be updated in-place
- B) The resource will be skipped
- **C) The resource will be destroyed and recreated** ✓
- D) The resource is being imported

**Q2:** Which command should you run after changing the backend configuration in your Terraform config?
- A) `terraform apply`
- **B) `terraform init -reconfigure`** ✓
- C) `terraform validate`
- D) `terraform refresh`

**Q3:** What does `terraform fmt -check` do?
- A) Formats all files and checks for errors
- B) Validates syntax of formatted files
- **C) Checks if files need formatting and exits non-zero if they do, without making changes** ✓
- D) Formats files and checks for provider compatibility

**Q4:** You want to apply infrastructure changes in a CI/CD pipeline without being prompted for confirmation. Which flag do you use?
- **A) `-auto-approve`** ✓
- B) `-force`
- C) `-yes`
- D) `-no-prompt`

**Q5:** `terraform refresh` is deprecated in Terraform 1.x. What is the recommended replacement?
- A) `terraform state sync`
- B) `terraform plan -refresh`
- **C) `terraform apply -refresh-only`** ✓
- D) `terraform validate -refresh`

**Q6:** In what order should these Terraform commands be run for a new project?
- **A) init → validate → plan → apply** ✓
- B) validate → init → plan → apply
- C) plan → init → validate → apply
- D) init → plan → validate → apply

---

## Lab Reference

**Run these in `/home/triplom/terraform-cert-work/local/`:**

```bash
terraform init                  # Initialize (downloads docker provider)
terraform fmt -check            # Check formatting
terraform validate              # Validate config
terraform plan                  # See what would be created
terraform plan -out=tfplan      # Save plan to file
terraform show tfplan           # Inspect saved plan
terraform apply -auto-approve   # Apply without prompt
terraform output                # View outputs
terraform show                  # View current state
terraform apply -refresh-only   # Sync state with reality (no changes)
terraform destroy -auto-approve # Tear down everything
```

---

*Previous: [Objective 2 — Terraform Fundamentals](./02-terraform-fundamentals.md)*
*Next: [Objective 4 — Terraform Configuration](./04-configuration.md)*
