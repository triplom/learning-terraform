# Objective 1: Understand Infrastructure as Code (IaC) Concepts

**Exam Weight:** ~7%
**Official Reference:** https://developer.hashicorp.com/terraform/tutorials/certification-004/associate-review-004

---

## 1.1 What is IaC?

Infrastructure as Code (IaC) is the practice of managing and provisioning infrastructure through machine-readable configuration files rather than through manual processes or interactive configuration tools.

### Key Properties of IaC
- **Declarative** — you define the *desired end state*, not the steps to get there
- **Idempotent** — applying the same config multiple times yields the same result
- **Version-controlled** — configs are stored in git, enabling history and rollback
- **Repeatable** — the same config produces identical infrastructure in any environment
- **Self-documenting** — the code itself describes what infrastructure exists

### Benefits of IaC
| Benefit | Description |
|---------|-------------|
| Consistency | Eliminates configuration drift and manual errors |
| Speed | Provision/destroy entire environments in minutes |
| Auditability | Every change tracked in version control |
| Collaboration | Teams work on infrastructure like application code |
| Reusability | Modules and templates shared across projects |
| Cost savings | Destroy environments when not needed |

---

## 1.2 IaC Approaches

### Declarative vs Imperative
| Approach | Description | Examples |
|----------|-------------|---------|
| **Declarative** | Define what you want; tool figures out how | Terraform, CloudFormation, Pulumi |
| **Imperative** | Define step-by-step how to get there | Bash scripts, Ansible (hybrid) |

Terraform is **declarative**. You write what the final state should look like; Terraform determines the sequence of API calls to make it real.

### Push vs Pull
| Approach | Description | Examples |
|----------|-------------|---------|
| **Push** | Central system pushes config to targets | Terraform, Ansible |
| **Pull** | Agents on targets pull config from central store | Chef, Puppet |

Terraform is **push-based** — the CLI pushes instructions to provider APIs.

---

## 1.3 IaC Tools Landscape

| Category | Tool | Notes |
|----------|------|-------|
| Provisioning | **Terraform** | Cloud-agnostic, declarative HCL |
| Provisioning | AWS CloudFormation | AWS-only, JSON/YAML |
| Provisioning | Pulumi | Uses general-purpose languages |
| Config Mgmt | Ansible | Agentless, YAML, hybrid declarative/imperative |
| Config Mgmt | Chef | Ruby DSL, pull-based, agent required |
| Config Mgmt | Puppet | Declarative, pull-based, agent required |
| Containers | Kubernetes manifests | Declarative YAML for container orchestration |

### Terraform's Differentiators
- **Provider ecosystem** — 3,000+ providers (AWS, Azure, GCP, GitHub, Datadog, etc.)
- **State management** — tracks real-world resource state in `terraform.tfstate`
- **Plan before apply** — shows exactly what will change before making changes
- **Multi-cloud** — manage resources across multiple clouds in one workflow
- **Open source core** — BSL licensed (was MPL-2.0 before Aug 2023)

---

## 1.4 Terraform-Specific IaC Concepts

### How Terraform Works
```
Write HCL → terraform init → terraform plan → terraform apply → Infrastructure
                                                                      ↓
                                                              terraform.tfstate
```

1. **Write** — Author `.tf` files describing desired infrastructure
2. **Init** — Download providers and modules; initialize backend
3. **Plan** — Compare desired state (config) vs current state (state file); generate execution plan
4. **Apply** — Execute the plan; call provider APIs to create/update/delete resources
5. **Destroy** — Tear down all managed resources

### Terraform State
- The state file (`terraform.tfstate`) is Terraform's source of truth about what it manages
- Without state, Terraform cannot know what resources already exist
- State enables **drift detection** (real world diverged from config)
- State enables **dependency tracking** (knows resource A must exist before B)

### Immutable vs Mutable Infrastructure
| Type | Description | Terraform Behavior |
|------|-------------|-------------------|
| **Mutable** | Resources are updated in-place | Some resources support in-place updates |
| **Immutable** | Resources are replaced (destroy + create) | `forces replacement` in plan output |

Terraform uses **immutable** approach by default for many resource properties (e.g., changing an EC2 AMI destroys and recreates the instance).

---

## 1.5 Exam-Focused Key Points

> These are the specific sub-objectives for Objective 1 on the exam:

### 1a. Explain what IaC is
- IaC manages infrastructure through code files (declarative/imperative)
- Terraform uses **declarative** HCL
- Key benefit: consistency, repeatability, auditability

### 1b. Describe advantages of IaC patterns
- Version control for infrastructure
- Collaboration via code review
- Automation of provisioning and teardown
- Self-service infrastructure for teams
- Reuse via modules

### 1c. Summarize the benefits of Terraform vs other IaC tools
- Cloud-agnostic (works with 3,000+ providers)
- Large community and registry of modules
- `plan` step provides safety before changes
- State file enables drift detection
- Open source with commercial HCP Terraform option

---

## Practice Questions

**Q1:** A team wants to ensure their AWS infrastructure is reproducible across dev, staging, and prod environments. Which IaC property primarily enables this?
- A) Idempotency
- B) Mutability
- **C) Repeatability** ✓
- D) Imperative execution

**Q2:** Terraform is described as a declarative tool. What does this mean?
- A) You define each API call Terraform should make
- **B) You define the desired end state and Terraform determines how to achieve it** ✓
- C) You write scripts that Terraform executes sequentially
- D) Terraform generates code from your existing infrastructure

**Q3:** Which of the following is NOT a benefit of using IaC?
- A) Version control for infrastructure changes
- B) Consistent environments across dev/staging/prod
- **C) Eliminates the need for cloud provider accounts** ✓
- D) Enables automated infrastructure provisioning

**Q4:** How does Terraform differ from configuration management tools like Ansible or Puppet?
- A) Terraform is pull-based
- B) Terraform requires agents on managed hosts
- **C) Terraform focuses on provisioning cloud resources, not configuring software on existing hosts** ✓
- D) Terraform only works with AWS

---

## Lab Reference

**Repo code to review:** `/local/main.tf` — see how a Docker-based provider is declared and resources are defined declaratively. Compare to what you would need to do manually with `docker run` commands.

```bash
# From /home/triplom/terraform-cert-work/local/
terraform plan   # See declarative plan output
```

---

*Next: [Objective 2 — Terraform Fundamentals](./02-terraform-fundamentals.md)*
