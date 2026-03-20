# Objective 8: Understand HCP Terraform's Capabilities

**Exam Weight:** ~11%
**Official Reference:** https://developer.hashicorp.com/terraform/tutorials/certification-004/associate-review-004

---

## 8.1 What is HCP Terraform?

**HCP Terraform** (formerly Terraform Cloud) is HashiCorp's managed service for Terraform. It provides:
- Remote state storage and locking
- Remote execution of Terraform operations
- Team collaboration and access control
- VCS-driven workflows
- Policy enforcement (Sentinel/OPA)
- Drift detection
- Private module and provider registries

**URL:** https://app.terraform.io

### HCP Terraform vs Open Source Terraform
| Feature | Open Source | HCP Terraform |
|---------|------------|---------------|
| CLI | Yes | Yes |
| State storage | Local/self-managed | Managed (encrypted) |
| Locking | Backend-dependent | Always available |
| Team access | No | Yes (RBAC) |
| Remote runs | No | Yes |
| VCS integration | No | Yes |
| Policy enforcement | No | Yes (Sentinel/OPA) |
| Audit logs | No | Yes |
| SSO | No | Yes (paid plans) |
| Private registry | No | Yes |

---

## 8.2 Workspaces in HCP Terraform

An HCP Terraform **workspace** is the fundamental unit — it contains:
- The Terraform configuration (linked to VCS or uploaded)
- State file
- Variables (Terraform and environment)
- Run history
- Access permissions

### HCP Terraform Workspace vs CLI Workspace
| | CLI Workspaces | HCP Terraform Workspaces |
|--|---------------|------------------------|
| State isolation | Yes | Yes |
| Variable isolation | No | Yes |
| Separate permissions | No | Yes |
| VCS integration | No | Yes |
| Recommended for | Dev/test | Production teams |

### Workspace Configuration Block
```hcl
terraform {
  cloud {
    organization = "my-organization"

    workspaces {
      name = "prod-network"
      # OR use tags to target multiple workspaces:
      # tags = ["network", "production"]
    }
  }
}
```

### Workspace States
| State | Description |
|-------|-------------|
| Pending | Run queued, waiting for queue |
| Planning | Running `terraform plan` |
| Policy Check | Sentinel/OPA policies being evaluated |
| Apply Pending | Plan approved, waiting to apply |
| Applying | Running `terraform apply` |
| Applied | Successfully applied |
| Errored | Run failed |

---

## 8.3 Projects

**Projects** are HCP Terraform organizational units that group related workspaces.

```
Organization
├── Project: Production
│   ├── Workspace: prod-network
│   ├── Workspace: prod-compute
│   └── Workspace: prod-database
├── Project: Staging
│   ├── Workspace: stg-network
│   └── Workspace: stg-compute
└── Project: Default (catch-all)
```

### Project Benefits
- Organize workspaces by team, environment, or application
- Apply project-level permissions (RBAC)
- Apply project-level variable sets
- Cleaner UI navigation

---

## 8.4 VCS-Driven Workflow

Connect HCP Terraform workspaces to a VCS repository (GitHub, GitLab, Bitbucket, Azure DevOps).

### How It Works
1. Developer pushes code to VCS repo
2. HCP Terraform detects changes via webhook
3. Speculative plan runs automatically on PRs
4. On merge to main: full plan + apply (or pending approval)

```
Developer → git push → GitHub → webhook → HCP Terraform
                                              │
                                    ┌─────────┴─────────┐
                                    │   terraform plan   │
                                    │ (speculative plan) │
                                    └─────────┬─────────┘
                                              │ approved
                                    ┌─────────┴─────────┐
                                    │  terraform apply   │
                                    └───────────────────┘
```

### Speculative Plans
- Run automatically on Pull Requests
- Read-only — never apply changes
- Results posted back to the PR as a status check
- Help catch issues before merging

---

## 8.5 CLI-Driven Workflow

Run Terraform commands from your local terminal, but state and execution happen in HCP Terraform.

```bash
# Login to HCP Terraform
terraform login

# Configure workspace in terraform block
# (uses 'cloud' block with organization and workspace)

# Standard commands — execution happens remotely
terraform init
terraform plan
terraform apply
```

### Remote Execution
- `terraform plan` / `apply` run on HCP Terraform's servers
- Logs stream back to your terminal
- State stored remotely automatically
- Good for teams that prefer CLI but want centralized state

---

## 8.6 Variables in HCP Terraform

HCP Terraform workspaces support two types of variables:

| Type | Description | Example |
|------|-------------|---------|
| **Terraform variables** | Correspond to `variable` blocks in your config | `instance_type = "t3.large"` |
| **Environment variables** | Set as OS env vars during runs | `AWS_ACCESS_KEY_ID`, `TF_LOG` |

### Variable Sets
Reusable collections of variables that can be applied to multiple workspaces or projects.

```
Variable Set: "AWS Production Credentials"
├── AWS_ACCESS_KEY_ID = (sensitive)
├── AWS_SECRET_ACCESS_KEY = (sensitive)
└── AWS_DEFAULT_REGION = "us-east-1"

Applied to: prod-network, prod-compute, prod-database workspaces
```

### Variable Precedence in HCP Terraform
1. Workspace-specific variables (highest)
2. Project variable sets
3. Global variable sets (lowest)

---

## 8.7 Sentinel and OPA Policies

**Policy enforcement** lets you define rules that must pass before `terraform apply` runs.

### Sentinel
- HashiCorp's proprietary policy framework (Plus/Enterprise plans)
- Written in the Sentinel language
- Policies run between `plan` and `apply`

```python
# Example: Require all instances to use approved AMIs
import "tfplan/v2" as tfplan

allowed_amis = ["ami-0c55b159cbfafe1f0", "ami-0a54c984b81079e52"]

main = rule {
  all tfplan.resource_changes as _, changes {
    changes.type != "aws_instance" or
    changes.change.after.ami in allowed_amis
  }
}
```

### Open Policy Agent (OPA)
- Open source alternative (available in all paid plans)
- Written in Rego language
- More flexible and interoperable with non-Terraform systems

### Policy Results
| Result | Behavior |
|--------|---------|
| Pass | Run proceeds to apply |
| Soft-Fail | Run can be overridden by authorized user |
| Hard-Fail | Run is blocked; cannot be overridden |

---

## 8.8 Drift Detection

HCP Terraform can automatically detect **drift** — when real infrastructure diverges from the Terraform state.

### How it Works
- HCP Terraform periodically runs `terraform plan -refresh-only`
- If drift is detected, an alert is shown in the workspace
- Does NOT auto-remediate (does not apply changes automatically)

### Responding to Drift
1. **Remediate drift** — run `terraform apply` to bring infra back to config
2. **Accept drift** — update config to match the changed reality
3. **Investigate** — determine what changed and why

---

## 8.9 HCP Terraform Plans

| Plan | State | Teams | SSO | Sentinel | Audit Logs |
|------|-------|-------|-----|---------|-----------|
| Free | Yes | 5 members | No | No | No |
| Plus | Yes | Unlimited | Yes | Yes | Yes |
| Enterprise | Yes | Unlimited | Yes | Yes | Yes |

> **Exam tip:** The free plan supports up to 5 members and has most basic features (remote state, VCS, runs). Sentinel and SSO require paid plans.

---

## 8.10 HCP Terraform Run Triggers

**Run triggers** allow one workspace to queue a run in another workspace when it applies successfully.

```
Workspace: networking ──applies──► triggers run in ──► Workspace: compute
```

Use case: When network infrastructure changes, automatically plan/apply dependent compute infrastructure.

---

## Practice Questions

**Q1:** What is the primary difference between HCP Terraform workspaces and local CLI workspaces?
- A) HCP Terraform workspaces do not support remote state
- B) Local CLI workspaces support Sentinel policies
- **C) HCP Terraform workspaces provide per-workspace variables, permissions, and VCS integration; CLI workspaces only provide state isolation** ✓
- D) They are functionally identical

**Q2:** A team wants Pull Request checks to show what infrastructure changes will be made before merging. Which HCP Terraform feature enables this?
- **A) Speculative plans via VCS integration** ✓
- B) Run triggers
- C) Sentinel policies
- D) Variable sets

**Q3:** What happens when a Sentinel policy returns a "soft-fail" result?
- A) The run is permanently blocked
- B) The plan is discarded and must be rerun
- **C) An authorized user can override the failure and allow the apply to proceed** ✓
- D) The policy is skipped and apply runs normally

**Q4:** Your organization has 10 workspaces that all need the same AWS credentials. What is the best way to manage this in HCP Terraform?
- A) Add the credentials to each workspace manually
- B) Hardcode them in the Terraform configuration
- **C) Create a variable set with the credentials and apply it to all workspaces** ✓
- D) Use a shared `terraform.tfvars` file committed to the repo

**Q5:** HCP Terraform detects drift in a workspace. What action does it take automatically?
- A) Runs `terraform apply` to remediate the drift
- **B) Alerts the team about the drift but does NOT automatically apply changes** ✓
- C) Rolls back the drifted resources to their previous state
- D) Locks the workspace until drift is resolved

**Q6:** Which HCP Terraform feature allows network workspace changes to automatically trigger a compute workspace run?
- A) Workspace scheduling
- B) Sentinel policies
- **C) Run triggers** ✓
- D) Variable sets

**Q7:** Which of the following requires a paid HCP Terraform plan?
- A) Remote state storage
- B) VCS integration
- **C) Sentinel policy enforcement** ✓
- D) CLI-driven workflow

---

## Lab Reference

HCP Terraform hands-on (requires free account at app.terraform.io):

```bash
# 1. Login to HCP Terraform
terraform login
# (opens browser, paste token)

# 2. Update terraform block to use cloud backend
# Edit local/main.tf to add:
# terraform {
#   cloud {
#     organization = "your-org-name"
#     workspaces { name = "kali-docker-lab" }
#   }
# }

# 3. Re-initialize to migrate state to HCP Terraform
terraform init -migrate-state

# 4. Run plan remotely
terraform plan   # Runs on HCP Terraform, logs stream to terminal

# 5. View workspace in browser
# https://app.terraform.io/app/your-org/workspaces/kali-docker-lab
```

**Explore the UI:**
- Workspace runs history
- State versions
- Variables configuration
- Sentinel/policy section (Plus plan only)
- Drift detection settings

---

*Previous: [Objective 7 — Maintain Infrastructure](./07-maintain-infrastructure.md)*
*Back to: [Overview README](../README.md)*
