# Objective 5: Interact with Terraform Modules

**Exam Weight:** ~15%
**Official Reference:** https://developer.hashicorp.com/terraform/tutorials/certification-004/associate-review-004

---

## 5.1 What is a Module?

A **module** is a container for multiple Terraform resources that are used together. Every Terraform configuration is a module — the directory you run Terraform from is the **root module**.

### Module Taxonomy
| Type | Description |
|------|-------------|
| **Root module** | The working directory where you run `terraform` commands |
| **Child module** | A module called by another module using a `module` block |
| **Published module** | A module in the public or private Terraform Registry |

### Why Use Modules?
- **Reusability** — package a VPC, ECS cluster, or Kubernetes deployment once; use many times
- **Encapsulation** — hide implementation complexity behind a clean interface (inputs/outputs)
- **Consistency** — enforce standards across environments (dev, staging, prod)
- **Collaboration** — share infrastructure patterns across teams

---

## 5.2 Module Structure

```
modules/
└── webapp/
    ├── main.tf        # Resources
    ├── variables.tf   # Input variables (module interface)
    ├── outputs.tf     # Output values (module interface)
    └── README.md      # Documentation
```

### Input Variables (module interface — inputs)
```hcl
# modules/webapp/variables.tf
variable "app_name" {
  type        = string
  description = "Name of the application"
}

variable "replicas" {
  type    = number
  default = 2
}
```

### Output Values (module interface — outputs)
```hcl
# modules/webapp/outputs.tf
output "service_endpoint" {
  description = "URL of the deployed service"
  value       = kubernetes_service.app.status[0].load_balancer[0].ingress[0].ip
}
```

### Root Module Calling Child Module
```hcl
# root main.tf
module "webapp" {
  source   = "./modules/webapp"     # Local path
  app_name = "my-app"
  replicas = 3
}

# Access module output
output "app_url" {
  value = module.webapp.service_endpoint
}
```

---

## 5.3 Module Sources

The `source` argument defines where Terraform fetches the module from.

### Local Path
```hcl
module "vpc" {
  source = "./modules/vpc"
  source = "../shared/modules/networking"
}
```
- Relative path to a local directory
- No download needed — used directly from filesystem
- NOT downloaded to `.terraform/modules/` (symlinked or referenced directly)

### Terraform Registry (Public)
```hcl
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"
}
```
- Format: `<namespace>/<module_name>/<provider>`
- Downloaded from `registry.terraform.io`

### GitHub / Generic Git
```hcl
module "vpc" {
  source = "github.com/hashicorp/example"
  source = "git::https://github.com/hashicorp/example.git?ref=v1.2.0"
  source = "git::ssh://git@github.com/org/repo.git//subdir?ref=main"
}
```

### Other Sources
```hcl
# Bitbucket
source = "bitbucket.org/org/module"

# S3 (AWS)
source = "s3::https://s3.amazonaws.com/bucket/module.zip"

# HTTP URL (zip file)
source = "https://example.com/module.zip"

# Private registry
source = "app.terraform.io/org/module/provider"
```

### Source Summary
| Source Type | Example | Version Argument? |
|-------------|---------|------------------|
| Local path | `"./modules/vpc"` | No |
| Public registry | `"hashicorp/vpc/aws"` | Yes (`version`) |
| GitHub | `"github.com/org/module"` | Via `?ref=` |
| Git | `"git::https://..."` | Via `?ref=` |
| Private registry | `"app.terraform.io/org/mod/prov"` | Yes (`version`) |

---

## 5.4 Module Versioning

```hcl
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"    # Allows 5.x but not 6.x
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = ">= 20.0, < 21.0"
}
```

> **Exam tip:** Version constraints are only supported for registry sources (public and private). Local paths and Git sources do NOT support the `version` argument — use `?ref=` for Git.

### `terraform init` and Modules
- Downloads module code to `.terraform/modules/`
- `terraform init -upgrade` fetches newer allowed module versions
- Module versions are also recorded in `.terraform.lock.hcl` (providers) but module versions are in `.terraform/modules/modules.json`

---

## 5.5 Module Scope and Variable Passing

Modules are isolated — they cannot directly access variables or resources from the parent module. Data flows explicitly through inputs and outputs.

```
Root Module
    │
    ├── var.region → module.vpc (input: region)
    │                    │
    │                    └── outputs: vpc_id, subnet_ids
    │
    └── module.vpc.vpc_id → module.eks (input: vpc_id)
                                 │
                                 └── outputs: cluster_endpoint
```

### Passing Data Between Modules
```hcl
# Root module
module "networking" {
  source = "./modules/networking"
  region = var.region
}

module "compute" {
  source    = "./modules/compute"
  vpc_id    = module.networking.vpc_id     # Using output from another module
  subnet_id = module.networking.subnet_ids[0]
}
```

---

## 5.6 The Public Terraform Registry

URL: https://registry.terraform.io

- **Modules** tab: Community and HashiCorp-verified modules
- **Providers** tab: Official, partner, and community providers

### Registry Module URL Format
```
registry.terraform.io/<namespace>/<module_name>/<provider>
```
Example: `registry.terraform.io/terraform-aws-modules/vpc/aws`

### Verified Modules
- Verified badge = reviewed by HashiCorp
- Higher trust than unverified community modules
- Still open source

---

## 5.7 Repo Example: kubernetes/modules/

The `kubernetes/modules/` directory in this repo is a perfect real-world module example:

```
kubernetes/
├── main.tf          # Root module — calls child modules
├── variables.tf     # Root variables
├── outputs.tf       # Root outputs
└── modules/
    ├── webapp/      # Child module: Kubernetes deployment + service
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    └── storage/     # Child module: PersistentVolumeClaim
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

### How Root Calls Modules
```hcl
# kubernetes/main.tf (simplified)
module "webapp" {
  source     = "./modules/webapp"
  app_name   = var.app_name
  image      = var.image
  replicas   = var.replicas
}

module "storage" {
  source        = "./modules/storage"
  storage_class = "standard"
  storage_size  = "1Gi"
}
```

---

## Practice Questions

**Q1:** Which module source type supports the `version` argument?
- A) Local paths only
- B) Git URLs only
- **C) Terraform Registry sources (public and private)** ✓
- D) All source types

**Q2:** A module is called with `source = "./modules/vpc"`. What does this tell Terraform?
- A) Download the module from the public registry
- **B) Use a local directory relative to the root module** ✓
- C) Clone from a Git repository
- D) Fetch from an S3 bucket

**Q3:** How does a root module pass a value to a child module?
- A) Using `locals` in the child module
- B) Using `terraform_remote_state`
- **C) Via input variables declared in the child module and set in the `module` block** ✓
- D) By directly referencing root module resources

**Q4:** After adding a new module to your configuration, what must you run before `terraform plan`?
- **A) `terraform init`** ✓
- B) `terraform validate`
- C) `terraform get`
- D) `terraform refresh`

**Q5:** You want to use the community module `terraform-aws-modules/eks/aws` version 20.x. Which configuration is correct?
```hcl
# Option A
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"
}

# Option B
module "eks" {
  source = "github.com/terraform-aws-modules/terraform-aws-eks"
  ref    = "v20.0.0"
}
```
- **A) Option A — correct registry source with version constraint** ✓
- B) Option B — correct GitHub source with ref
- C) Both are equivalent
- D) Neither is valid HCL

**Q6:** Can a child module access variables or resources directly from the root module without being passed explicitly?
- **A) No — modules are isolated; data flows only through inputs (variables) and outputs** ✓
- B) Yes — child modules inherit the root module's variables
- C) Yes — using the `inherit` meta-argument
- D) Only if the child module uses `terraform_remote_state`

---

## Lab Reference

**Explore the kubernetes module in this repo:**
```bash
# From /home/triplom/terraform-cert-work/
cat kubernetes/main.tf           # See how modules are called
cat kubernetes/modules/webapp/main.tf      # See child module resources
cat kubernetes/modules/webapp/variables.tf # See module input interface
cat kubernetes/modules/webapp/outputs.tf   # See module output interface
cat kubernetes/modules/storage/main.tf     # Second child module
```

**Public registry exploration:**
- Browse modules at https://registry.terraform.io/browse/modules
- Find `terraform-aws-modules/vpc/aws` — the most popular Terraform module

---

*Previous: [Objective 4 — Configuration](./04-configuration.md)*
*Next: [Objective 6 — State Management](./06-state-management.md)*
