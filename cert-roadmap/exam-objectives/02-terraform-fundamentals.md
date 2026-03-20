# Objective 2: Understand Terraform's Purpose (vs Other IaC)

**Exam Weight:** ~15%
**Official Reference:** https://developer.hashicorp.com/terraform/tutorials/certification-004/associate-review-004

---

## 2.1 Terraform Providers

Providers are plugins that let Terraform manage resources on a specific platform or service.

### How Providers Work
```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}
```

- **Source format:** `<namespace>/<type>` (e.g., `hashicorp/aws`, `kreuzwerker/docker`)
- Providers are downloaded from the **Terraform Registry** (registry.terraform.io) during `terraform init`
- Providers are stored in `.terraform/providers/` directory (local cache)
- Each provider exposes **resources** and **data sources**

### Provider Tiers
| Tier | Maintained By | Example |
|------|--------------|---------|
| **Official** | HashiCorp | `hashicorp/aws`, `hashicorp/azurerm`, `hashicorp/google` |
| **Partner** | Technology partner (verified) | `datadog/datadog`, `mongodb/mongodbatlas` |
| **Community** | Open source community | `kreuzwerker/docker` |

### Provider Versioning
```hcl
version = "~> 5.0"    # >= 5.0, < 6.0 (patch + minor updates, NOT major)
version = ">= 5.0"    # 5.0 or higher (any version)
version = "= 5.1.2"   # exactly 5.1.2
version = ">= 5.0, < 6.0"  # explicit range
```

**Constraint operators:**
- `~>` — pessimistic constraint (allows rightmost increment only)
- `>=` / `<=` — minimum / maximum
- `!=` — exclude specific version
- `=` — exact version (pin)

### Repo Example
See `/aws/providers.tf` and `/local/main.tf` in the repo — both demonstrate `required_providers` with version constraints.

---

## 2.2 Terraform State

State is Terraform's record of the infrastructure it manages. It maps config resources to real-world objects.

### State File (`terraform.tfstate`)
```json
{
  "version": 4,
  "terraform_version": "1.12.0",
  "serial": 5,
  "lineage": "abc123...",
  "resources": [
    {
      "mode": "managed",
      "type": "docker_container",
      "name": "tomcat",
      "provider": "provider[\"registry.terraform.io/kreuzwerker/docker\"]",
      "instances": [...]
    }
  ]
}
```

### Why State Matters
| Purpose | Description |
|---------|-------------|
| **Mapping** | Links config resources to real infrastructure IDs |
| **Metadata** | Stores resource dependencies and provider info |
| **Performance** | Caches resource attributes (avoids querying all APIs on every plan) |
| **Drift detection** | Compare desired vs actual state |
| **Sync** | With remote backends, teams share state safely |

### State Storage Options
| Type | Description | Use Case |
|------|-------------|---------|
| **Local** | `terraform.tfstate` in working directory | Development, single user |
| **Remote** | S3, Azure Blob, GCS, HCP Terraform | Teams, CI/CD pipelines |

> **Exam tip:** Never manually edit the state file. Use `terraform state` commands instead.

### State Locking
- Prevents concurrent state modifications (race conditions)
- Supported by most remote backends (S3+DynamoDB, HCP Terraform, etc.)
- Local backend does NOT support locking
- Error: `Error acquiring the state lock`

---

## 2.3 Terraform Versions

### Version Pinning
```hcl
terraform {
  required_version = ">= 1.0, < 2.0"
}
```

- Enforced at `terraform init` and `plan`
- Protects against incompatible Terraform versions running your config

### Version Management Tools
| Tool | Description |
|------|-------------|
| `tfenv` | Popular version manager for Terraform (like `nvm` for Node) |
| `asdf` | Multi-language version manager, supports Terraform |
| HCP Terraform | Enforces Terraform version per workspace |

### Terraform Release Types
| Type | Example | Notes |
|------|---------|-------|
| Stable | `1.12.0` | Production recommended |
| Alpha | `1.13.0-alpha1` | Preview, not for production |
| Beta | `1.13.0-beta1` | Testing, not for production |
| Release Candidate | `1.13.0-rc1` | Near-final, not for production |

---

## 2.4 The Dependency Lock File (`.terraform.lock.hcl`)

The lock file records the exact provider versions and checksums selected during `terraform init`.

### Example Lock File
```hcl
# This file is maintained automatically by "terraform init".
# Manual edits may be lost in future updates.

provider "registry.terraform.io/hashicorp/aws" {
  version     = "5.31.0"
  constraints = "~> 5.0"
  hashes = [
    "h1:abc123...",
    "zh:def456...",
  ]
}
```

### Key Behaviors
| Behavior | Detail |
|----------|--------|
| **Commit to VCS** | YES — lock file should be committed to git |
| **Auto-generated** | Created/updated by `terraform init` |
| **Provider pinning** | Locks exact provider version across team |
| **Upgrade** | Use `terraform init -upgrade` to update locked versions |
| **Checksum** | Verifies provider binary integrity |

### Lock File vs `required_providers`
| | `required_providers` | `.terraform.lock.hcl` |
|--|---------------------|----------------------|
| Purpose | Define acceptable version range | Pin exact version used |
| Edited by | Developer | Terraform automatically |
| Committed? | Yes | Yes |
| Enforced at | Init, plan, apply | Init |

> **Exam tip:** The `.terraform.lock.hcl` file should **always** be committed to version control. The `.terraform/` directory should **not** be committed (add to `.gitignore`).

---

## 2.5 Exam-Focused Key Points

### 2a. Explain the purpose of Terraform state
- Tracks mapping between config and real-world resources
- Enables drift detection, dependency tracking, performance caching
- Should be stored remotely for team use

### 2b. Describe Terraform provider installation and versioning
- Providers downloaded during `terraform init`
- Version constraints defined in `required_providers`
- Lock file pins exact versions for reproducibility

### 2c. Describe how Terraform finds and fetches providers
- Default source: Terraform Registry (`registry.terraform.io`)
- Can use private registries or local filesystem mirrors
- `terraform init` downloads to `.terraform/providers/`

### 2d. Describe the purpose of the Terraform dependency lock file
- Ensures same provider version used by all team members
- Must be committed to version control
- Updated with `terraform init -upgrade`

---

## Practice Questions

**Q1:** A team uses `~> 4.0` as the version constraint for the AWS provider. Which versions are allowed?
- A) Only 4.0.0 exactly
- B) 4.x.x and 5.x.x
- **C) >= 4.0.0 and < 5.0.0** ✓
- D) Any version >= 4.0.0

**Q2:** What is the purpose of the `.terraform.lock.hcl` file?
- A) Store Terraform state for local backends
- B) Define which providers are required
- **C) Lock provider versions and checksums for reproducibility** ✓
- D) Cache module source code locally

**Q3:** Where does Terraform store provider plugins after `terraform init`?
- **A) `.terraform/providers/` directory** ✓
- B) `~/.terraform/` in the home directory
- C) `/usr/local/bin/`
- D) `terraform.tfstate`

**Q4:** Your team added a new developer. They ran `terraform init` and got a different provider version than the rest of the team. What is the most likely cause?
- A) They used a different `required_providers` block
- **B) The `.terraform.lock.hcl` file was not committed to version control** ✓
- C) Their Terraform CLI version is different
- D) They used a different region in the provider block

**Q5:** Which of the following is TRUE about Terraform state?
- A) State is only needed for remote backends
- B) You should edit the state file directly to fix drift
- **C) State maps configuration resources to real-world infrastructure objects** ✓
- D) State is optional for single-resource configurations

---

## Lab Reference

**Repo files to review:**
- `/local/main.tf` — provider block with `kreuzwerker/docker ~> 3.0`
- `/aws/providers.tf` — `hashicorp/aws ~> 5.0` with version constraint
- `/local/terraform.tfstate` — actual state file from a previous apply (examine structure)
- `/.terraform.lock.hcl` (if present after init) — lock file example

```bash
# From /home/triplom/terraform-cert-work/local/
cat terraform.tfstate          # Inspect state file structure
cat .terraform.lock.hcl        # (after init) Inspect lock file
terraform providers            # List providers used in current config
terraform version              # Show Terraform + provider versions
```

---

*Previous: [Objective 1 — IaC Concepts](./01-iac-concepts.md)*
*Next: [Objective 3 — Core Workflow](./03-core-workflow.md)*
