# Exam Tips — HashiCorp Certified Terraform Associate (004)

High-value facts, common traps, and memory aids for the exam.

---

## Exam Quick Facts

| Detail | Value |
|--------|-------|
| Exam code | Terraform Associate 004 |
| Questions | ~57 |
| Duration | 60 minutes |
| Passing score | ~70% (~40 correct) |
| Cost | $70.50 USD |
| Format | Multiple choice, multiple select |
| Allowed | Open browser (NOT ChatGPT or forums) |
| Delivery | PSI Online Proctoring or Test Center |

---

## Top Exam Traps (Frequently Tested)

### 1. Variable Precedence
Order from **lowest to highest** (highest wins):
```
Default value
→ terraform.tfvars
→ *.auto.tfvars (alphabetical)
→ -var-file flag
→ -var flag
→ TF_VAR_name environment variable  ← HIGHEST
```
> **Trap:** Many sources list env vars as lowest, but in Terraform they're HIGHEST.

### 2. `terraform refresh` is Deprecated
- DO NOT use `terraform refresh` — it is **deprecated**
- Use `terraform apply -refresh-only` instead
- This is an active exam question

### 3. `terraform taint` is Deprecated
- DO NOT use `terraform taint` — it is **deprecated**
- Use `terraform apply -replace=<address>` instead

### 4. `terraform fmt` vs `terraform validate`
| | `fmt` | `validate` |
|--|-------|-----------|
| What it does | Formats code style | Checks syntax/logic |
| Needs init? | No | Yes |
| Contacts APIs? | No | No |
| Fixes files? | Yes | No |

### 5. `sensitive = true` Does NOT Encrypt State
- Sensitive values ARE stored in state (plaintext)
- They are only **redacted from CLI output**
- You must secure the state file separately (encrypted backend)

### 6. `prevent_destroy` Does NOT Prevent `state rm`
- `prevent_destroy = true` blocks `terraform apply` from destroying
- It does NOT prevent `terraform state rm` (manual state removal)
- It does NOT prevent someone from removing the `lifecycle` block and re-applying

### 7. Lock File Must Be Committed
- `.terraform.lock.hcl` **must** be committed to VCS
- `.terraform/` directory must **NOT** be committed (add to `.gitignore`)
- Lock file records exact provider versions and checksums

### 8. `count` vs `for_each`
- Removing a `count` item renumbers the list → can cause unexpected replacements
- Removing a `for_each` item only removes that specific key → safe
- Prefer `for_each` for resources with unique identities

### 9. Local Workspaces ≠ HCP Terraform Workspaces
- Local CLI workspaces: only state isolation, no variable isolation
- HCP Terraform workspaces: full isolation (state, vars, permissions, VCS)
- Local workspaces are NOT recommended for team production use

### 10. `terraform_remote_state` Only Exposes Outputs
- You can only access `outputs` from the remote state, not individual resource attributes
- The remote config must define `output` blocks for values you want to share

---

## Command Memory Aids

### "Always needs init after change"
- Added/changed a provider → re-run `terraform init`
- Added/changed a module source → re-run `terraform init`
- Changed backend config → re-run `terraform init -reconfigure`

### "Plan is read-only"
- `terraform plan` NEVER modifies infrastructure or state
- `terraform validate` NEVER modifies infrastructure or state
- `terraform fmt` NEVER modifies infrastructure (only code files)
- Only `apply` and `destroy` make changes

### "state rm ≠ destroy"
- `terraform state rm` removes from **Terraform's tracking** only
- The real resource **continues to exist** in the cloud
- Opposite: `terraform import` brings untracked resource **into** tracking

---

## Provider Version Constraint Operators

```
~> 5.0    → >= 5.0.0 AND < 6.0.0   (allows patch + minor within major)
~> 5.1    → >= 5.1.0 AND < 5.2.0   (allows patch within minor)
~> 5.1.2  → >= 5.1.2 AND < 5.2.0   (allows patch within minor, starting at 5.1.2)
>= 5.0    → 5.0 or higher (no upper bound)
= 5.1.2   → exactly 5.1.2
!= 5.0.0  → anything except 5.0.0
```
> The `~>` operator is called **pessimistic constraint** — allows rightmost specified digit to increment.

---

## Lifecycle Arguments Summary

| Argument | Effect | Use When |
|----------|--------|---------|
| `create_before_destroy = true` | New resource created before old destroyed | Zero-downtime replacement |
| `prevent_destroy = true` | Block any destroy of this resource | Databases, critical resources |
| `ignore_changes = [attr, ...]` | Ignore out-of-band changes to these attributes | Resources modified externally |
| `replace_triggered_by = [...]` | Force replacement when referenced objects change | Redeploy when config changes |

---

## Module Source Quick Reference

| Source | Format | Version Arg? |
|--------|--------|-------------|
| Local path | `"./modules/vpc"` | No |
| Public registry | `"hashicorp/vpc/aws"` | Yes (`version`) |
| GitHub HTTPS | `"github.com/org/module"` | No (use `?ref=`) |
| Git URL | `"git::https://..."` | No (use `?ref=`) |
| Private registry | `"app.terraform.io/org/mod/prov"` | Yes (`version`) |

> Version constraints work ONLY with registry sources. Use `?ref=tag` for Git.

---

## Plan Symbols

| Symbol | Meaning |
|--------|---------|
| `+` | Will be **created** |
| `-` | Will be **destroyed** |
| `~` | Will be **updated in-place** |
| `-/+` | Will be **replaced** (destroy + create) |
| `<=` | Data source will be **read** |

---

## Backend Comparison

| Backend | Locking | Use Case |
|---------|---------|---------|
| Local | No | Solo dev, learning |
| S3 + DynamoDB | Yes (DynamoDB) | AWS teams |
| Azure Blob | Yes | Azure teams |
| GCS | Yes | GCP teams |
| HCP Terraform | Yes | Any team, full features |

> Local backend has NO locking — concurrent applies can corrupt state.

---

## HCP Terraform Key Facts

- **Speculative plans**: runs on PRs, never apply, posted as PR check
- **Variable sets**: reusable variables applied to multiple workspaces
- **Run triggers**: workspace A applies → automatically triggers workspace B
- **Sentinel**: proprietary policy language (Plus/Enterprise plans only)
- **OPA**: open-source alternative policy (paid plans)
- **Soft-fail**: authorized user can override
- **Hard-fail**: completely blocks apply, cannot be overridden
- **Free plan**: up to 5 users, basic features (no Sentinel, no SSO)
- **Drift detection**: detects drift via periodic refresh-only plans, does NOT auto-remediate

---

## State File Key Fields

```
version          → State format version (currently 4)
terraform_version → Terraform CLI version last used
serial           → Increments on every change (conflict detection)
lineage          → UUID, uniquely identifies this state (created once)
resources[]      → Array of managed resources
outputs{}        → Current output values
```

---

## Frequently Tested Commands

These commands appear often in exam questions:

```bash
terraform init -upgrade              # Upgrade locked providers
terraform init -reconfigure          # Reconfigure backend
terraform init -migrate-state        # Move state to new backend
terraform plan -out=plan.out         # Save plan
terraform apply plan.out             # Apply saved plan
terraform apply -refresh-only        # Detect drift (replaces refresh)
terraform apply -replace=res.name    # Force replace (replaces taint)
terraform apply -destroy             # Destroy (same as terraform destroy)
terraform state mv old new           # Rename in state
terraform state rm resource          # Remove from state
terraform force-unlock LOCK_ID       # Release stuck lock
terraform workspace new env          # Create workspace
terraform workspace select env       # Switch workspace
export TF_LOG=TRACE                  # Enable verbose logging
export TF_VAR_name=value             # Set variable via env
```

---

## 5-Minute Pre-Exam Checklist

- [ ] `terraform refresh` is DEPRECATED → use `apply -refresh-only`
- [ ] `terraform taint` is DEPRECATED → use `apply -replace`
- [ ] Env vars `TF_VAR_*` have HIGHEST precedence
- [ ] Lock file (`.terraform.lock.hcl`) → COMMIT to git
- [ ] `.terraform/` directory → DO NOT commit (gitignore it)
- [ ] `sensitive = true` → redacts CLI output, does NOT encrypt state
- [ ] `state rm` → removes from tracking, does NOT destroy resource
- [ ] `for_each` preferred over `count` for named resources
- [ ] Module `version` arg only works with registry sources
- [ ] `terraform_remote_state` only exposes `output` values
- [ ] Local workspaces = state isolation only (no variable isolation)
- [ ] `prevent_destroy` blocks `apply`, NOT `state rm`

---

*See also: [Terraform Commands](./terraform-commands.md) | [HCL Syntax](./hcl-syntax.md) | [State Commands](./state-commands.md)*
