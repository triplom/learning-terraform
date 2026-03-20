# Terraform Associate Certification Roadmap

> **Exam:** HashiCorp Certified: Terraform Associate (004)
> **Version tested:** Terraform 1.12
> **Format:** ~57 questions — true/false, multiple choice, multiple answer
> **Duration:** 60 minutes
> **Passing score:** 70%
> **Cost:** $70.50 USD
> **Registration:** https://developer.hashicorp.com/certifications/infrastructure-automation

This branch (`cert-roadmap`) adds a structured certification learning path on top of the existing `learning-terraform` repository. All hands-on labs reference code that already exists in this repo (`local/`, `aws/`, `azure/`, `kubernetes/`).

---

## Why This Repo Is Perfect for Cert Prep

The code in this repository already demonstrates nearly every exam objective:

| Repo Module | Exam Objectives Covered |
|-------------|------------------------|
| `local/` | Providers, resources, outputs, variables, state — zero cloud cost |
| `aws/` | Multi-provider usage, resource lifecycle, variables, remote state |
| `azure/` | Multi-cloud patterns, AzureRM provider, equivalent resource mapping |
| `kubernetes/` | Modules (local), module variables/outputs, reusable module structure |
| Root `main.tf` | IaC basics, core workflow, terraform block, dependency lock |

---

## Certification Roadmap Structure

```
cert-roadmap/
├── README.md                      ← this file (overview + quick-start)
├── study-plan/
│   └── README.md                  ← 8-week study plan, week-by-week
├── exam-objectives/
│   ├── 01-iac-concepts.md         ← Objective 1: IaC with Terraform
│   ├── 02-terraform-fundamentals.md ← Objective 2: Fundamentals
│   ├── 03-core-workflow.md        ← Objective 3: Core workflow
│   ├── 04-configuration.md        ← Objective 4: HCL configuration
│   ├── 05-modules.md              ← Objective 5: Modules
│   ├── 06-state-management.md     ← Objective 6: State management
│   ├── 07-maintain-infrastructure.md ← Objective 7: Maintenance
│   └── 08-hcp-terraform.md        ← Objective 8: HCP Terraform
├── cheatsheets/
│   ├── terraform-commands.md      ← All CLI commands with flags
│   ├── hcl-syntax.md              ← HCL blocks, types, expressions
│   ├── state-commands.md          ← State management commands
│   └── exam-tips.md               ← Exam-day tips and common gotchas
├── resources/
│   ├── courses.md                 ← Your courses mapped to objectives
│   ├── official.md                ← HashiCorp official resources
│   └── practice-tests.md         ← Where to find practice questions
└── labs/
    └── README.md                  ← Hands-on lab exercises using this repo
```

---

## Quick Start: 8-Week Roadmap

| Week | Focus | Exam Objective | This Repo |
|------|-------|---------------|-----------|
| 1 | IaC concepts + install + local provider | 1, 2a–2c | `local/` |
| 2 | Core workflow: init/plan/apply/destroy | 3 | `local/`, `aws/` |
| 3 | HCL deep dive: resources, variables, outputs, data | 4a–4c | `aws/`, `azure/` |
| 4 | Advanced HCL: functions, expressions, lifecycle | 4d–4h | `aws/`, `kubernetes/` |
| 5 | State: local, remote, locking, drift | 6 | `aws/` + S3 backend |
| 6 | Modules: registry, local, versioning | 5 | `kubernetes/modules/` |
| 7 | Maintenance: import, logging, troubleshoot | 7 | All modules |
| 8 | HCP Terraform + final review + practice exam | 8 | HCP workspace |

See [`study-plan/README.md`](./study-plan/README.md) for the detailed week-by-week breakdown.

---

## Exam Objectives at a Glance

The exam has **8 objectives**:

1. **IaC with Terraform** — what IaC is, advantages, multi-cloud
2. **Terraform Fundamentals** — providers, state, versions, dependency lock
3. **Core Workflow** — init → fmt → validate → plan → apply → destroy
4. **Terraform Configuration** — HCL: resources, data, variables, outputs, functions, lifecycle, sensitive data
5. **Modules** — sourcing, variable scope, versioning, registry vs local
6. **State Management** — local/remote backends, state locking, drift, moved/removed blocks
7. **Maintain Infrastructure** — import, state CLI, verbose logging
8. **HCP Terraform** — workspaces, projects, VCS workflow, policies, drift detection

---

## Your Courses Mapped to Objectives

| Course | Platform | Objectives |
|--------|----------|-----------|
| Terraform Essentials | LinuxTips (school.linuxtips.io) | 1, 2, 3, 4 |
| Learning Terraform | LinkedIn Learning | 1, 2, 3, 4, 5 |
| HashiCorp Certified Terraform Associate | Udemy (StackSimplify) | All 8 — 50 demos |

See [`resources/courses.md`](./resources/courses.md) for detailed chapter mappings.

---

## Prerequisites

- Terraform >= 1.3 installed (`terraform --version`)
- Docker running (for `local/` labs — no cloud account needed)
- AWS CLI configured (for `aws/` labs — optional but recommended)
- Azure CLI configured (for `azure/` labs — optional)
- `kubectl` + kind/minikube (for `kubernetes/` labs — optional)

```bash
# Verify Terraform installation
terraform --version

# Run the local lab (no cloud account needed)
cd local/
terraform init
terraform plan
terraform apply
terraform output
terraform destroy
```
