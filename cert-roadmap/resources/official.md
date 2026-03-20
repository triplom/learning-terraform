# Official HashiCorp Resources

All official documentation and study materials for the Terraform Associate (004) exam.

---

## Exam Registration

| Item | Link |
|------|------|
| Exam overview | https://developer.hashicorp.com/certifications/infrastructure-automation |
| Register (PSI) | https://hashicorp-certifications.zendesk.com/hc/en-us |
| Exam cost | $70.50 USD |
| Retake policy | 24 hours wait after first fail; 14 days after each subsequent fail |

---

## Exam Prep (Official)

| Resource | URL |
|----------|-----|
| Study guide (004) | https://developer.hashicorp.com/terraform/tutorials/certification-004/associate-study-004 |
| Exam review (004) | https://developer.hashicorp.com/terraform/tutorials/certification-004/associate-review-004 |
| Sample questions | https://developer.hashicorp.com/terraform/tutorials/certification-004/associate-questions |
| Exam objectives | Listed at the review link above |

> Start with the **exam review** page — it lists every sub-objective with links to the relevant documentation.

---

## Core Documentation

| Topic | URL |
|-------|-----|
| Terraform CLI docs | https://developer.hashicorp.com/terraform/cli |
| Language reference | https://developer.hashicorp.com/terraform/language |
| Provider registry | https://registry.terraform.io |
| Module registry | https://registry.terraform.io/browse/modules |

---

## Language Reference (by Objective)

### Objective 1: IaC Concepts
- https://developer.hashicorp.com/terraform/intro

### Objective 2: Fundamentals (Providers, State, Lock File)
- https://developer.hashicorp.com/terraform/language/providers
- https://developer.hashicorp.com/terraform/language/state
- https://developer.hashicorp.com/terraform/language/files/dependency-lock

### Objective 3: Core Workflow
- https://developer.hashicorp.com/terraform/cli/commands/init
- https://developer.hashicorp.com/terraform/cli/commands/fmt
- https://developer.hashicorp.com/terraform/cli/commands/validate
- https://developer.hashicorp.com/terraform/cli/commands/plan
- https://developer.hashicorp.com/terraform/cli/commands/apply
- https://developer.hashicorp.com/terraform/cli/commands/destroy

### Objective 4: Configuration
- https://developer.hashicorp.com/terraform/language/resources
- https://developer.hashicorp.com/terraform/language/data-sources
- https://developer.hashicorp.com/terraform/language/values/variables
- https://developer.hashicorp.com/terraform/language/values/outputs
- https://developer.hashicorp.com/terraform/language/values/locals
- https://developer.hashicorp.com/terraform/language/functions
- https://developer.hashicorp.com/terraform/language/meta-arguments/lifecycle

### Objective 5: Modules
- https://developer.hashicorp.com/terraform/language/modules
- https://developer.hashicorp.com/terraform/language/modules/sources

### Objective 6: State Management
- https://developer.hashicorp.com/terraform/language/state
- https://developer.hashicorp.com/terraform/language/backend
- https://developer.hashicorp.com/terraform/cli/workspaces
- https://developer.hashicorp.com/terraform/language/moved

### Objective 7: Maintain Infrastructure
- https://developer.hashicorp.com/terraform/cli/commands/import
- https://developer.hashicorp.com/terraform/cli/commands/state
- https://developer.hashicorp.com/terraform/internals/debugging

### Objective 8: HCP Terraform
- https://developer.hashicorp.com/terraform/cloud-docs
- https://developer.hashicorp.com/terraform/cloud-docs/workspaces
- https://developer.hashicorp.com/terraform/cloud-docs/policy-enforcement

---

## Official Tutorials (Hands-On)

These are the exact tutorials referenced from the study guide:

| Tutorial | Objective |
|----------|-----------|
| https://developer.hashicorp.com/terraform/tutorials/aws-get-started | All basics |
| https://developer.hashicorp.com/terraform/tutorials/configuration-language | Obj 4 |
| https://developer.hashicorp.com/terraform/tutorials/modules | Obj 5 |
| https://developer.hashicorp.com/terraform/tutorials/state | Obj 6, 7 |
| https://developer.hashicorp.com/terraform/tutorials/cloud | Obj 8 |

---

## Terraform Changelog (004-Specific Features)

The 004 exam targets **Terraform 1.x** with emphasis on features since 1.1:

| Version | Feature | Objective |
|---------|---------|-----------|
| 1.1 | `moved` block | Obj 6, 7 |
| 1.2 | `precondition`/`postcondition` | Obj 4 |
| 1.3 | Optional object attributes | Obj 4 |
| 1.5 | `import` block, `-generate-config-out` | Obj 7 |
| 1.6 | Test framework (`terraform test`) | N/A |
| 1.7 | `removed` block, `mock` providers | Obj 6 |
| 1.8 | Provider functions | Obj 4 |
| 1.9 | Variable/output descriptions in JSON | N/A |
| 1.10 | Stacks (preview) | N/A |
| 1.12 | Current exam version | All |

---

## Terraform GitHub Repositories

| Repo | Description |
|------|-------------|
| https://github.com/hashicorp/terraform | Terraform CLI (open source) |
| https://github.com/hashicorp/terraform-provider-aws | AWS provider |
| https://github.com/terraform-aws-modules | Popular AWS modules |

---

*See also: [Courses](./courses.md) | [Practice Tests](./practice-tests.md)*
