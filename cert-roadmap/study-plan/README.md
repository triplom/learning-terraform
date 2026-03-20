# 8-Week Terraform Associate (004) Study Plan

> **Goal:** Pass the HashiCorp Certified Terraform Associate (004) exam
> **Time commitment:** ~10–15 hours/week
> **Total:** ~8 weeks (can compress to 4–5 weeks with more daily study)
> **Exam version:** Terraform 1.12

All hands-on exercises use code already in **this repository**. Start with `local/` (no cloud account needed), then layer in `aws/` or `azure/` for remote state and cloud-specific labs.

---

## Prerequisites (Before Week 1)

- [ ] Install Terraform >= 1.3: https://developer.hashicorp.com/terraform/install
- [ ] Install Docker (for `local/` labs): already installed on Kali
- [ ] Clone this repo and verify `local/` works:
  ```bash
  cd local/
  terraform init && terraform apply && terraform destroy
  ```
- [ ] Create a free HCP Terraform account: https://app.terraform.io
- [ ] Optional: Configure AWS CLI (`aws configure`) for `aws/` labs
- [ ] Optional: Configure Azure CLI (`az login`) for `azure/` labs

---

## Week 1 — IaC Concepts + Providers + First Config

**Exam Objectives:** 1 (IaC), 2a–2c (Fundamentals: providers)

### Concepts to Master
- What is Infrastructure as Code and why it matters
- Idempotency, declarative vs imperative IaC
- Terraform's place in the IaC landscape (vs Ansible, CloudFormation, Pulumi)
- Multi-cloud and service-agnostic workflows
- What a provider is and how Terraform uses plugins
- The `terraform` block (required_version, required_providers)
- The `provider` block (source, version constraints)
- The `.terraform.lock.hcl` dependency lock file

### Hands-on Labs (this repo)
```bash
# Lab 1: Understand the local module provider config
cat local/providers.tf

# Lab 2: Init and inspect what gets downloaded
cd local/
terraform init
cat .terraform.lock.hcl
ls .terraform/providers/

# Lab 3: Examine the terraform block + required_providers
cat local/providers.tf   # kreuzwerker/docker provider
cat aws/providers.tf     # hashicorp/aws provider
cat azure/providers.tf   # hashicorp/azurerm provider
# Note different sources, version constraints

# Lab 4: See multiple providers in one config
cat kubernetes/providers.tf
```

### Key Questions to Answer
- What is the format for provider `source`? (`<registry>/<namespace>/<name>`)
- What does `~> 5.0` mean in a version constraint?
- What is in `.terraform.lock.hcl` and why is it committed to git?
- What command downloads providers? (`terraform init`)

### Resources This Week
- **LinuxTips Terraform Essentials** — Units 1–3 (IaC basics, install, first config)
- **LinkedIn Learning** — Chapters 1–2 (What is Terraform, Setting Up)
- Official: https://developer.hashicorp.com/terraform/intro
- Official: https://developer.hashicorp.com/terraform/language/providers

---

## Week 2 — Core Workflow: init → fmt → validate → plan → apply → destroy

**Exam Objectives:** 3 (Core Terraform workflow — all sub-objectives)

### Concepts to Master
- The three-stage core workflow: Write → Plan → Apply
- `terraform init` — what it does (downloads providers, initializes backend, installs modules)
- `terraform fmt` — auto-formatting HCL to canonical style
- `terraform validate` — syntax and internal consistency check (no API calls)
- `terraform plan` — creates execution plan, shows +/-/~ changes
- `terraform apply` — applies the plan, updates state
- `terraform destroy` — destroys all managed infrastructure
- Plan files: `terraform plan -out=tfplan` and `terraform apply tfplan`
- Dependency graph: how Terraform determines creation order
- `depends_on` meta-argument (explicit dependencies)

### Hands-on Labs (this repo)
```bash
cd local/

# Lab 1: Full workflow from scratch
terraform init
terraform fmt          # should show no changes (files are pre-formatted)
terraform validate     # should show "Success!"
terraform plan         # review: what will be created?
terraform apply        # type 'yes' or use -auto-approve
terraform output       # see outputs
terraform destroy      # clean up

# Lab 2: Save and use a plan file
terraform plan -out=myplan.tfplan
terraform show myplan.tfplan      # inspect saved plan
terraform apply myplan.tfplan     # apply it (no confirmation needed)

# Lab 3: Intentionally break the syntax, run validate
echo "bad_block {" >> variables.tf
terraform validate     # should fail with error
git checkout variables.tf

# Lab 4: View dependency graph
terraform graph | head -30
# Install graphviz to render: apt install graphviz
# terraform graph | dot -Tsvg > graph.svg

# Lab 5: Repeat with aws/ module (if AWS configured)
cd ../aws/
terraform init && terraform plan
```

### Key Questions to Answer
- Does `terraform validate` contact cloud APIs? (No)
- Does `terraform plan` change infrastructure? (No)
- What does `~` mean in plan output? (in-place update)
- What does `-/+` mean? (destroy and recreate)
- When is a plan file useful? (CI/CD pipelines)

### Resources This Week
- **LinkedIn Learning** — Chapters 3–4 (Core commands)
- **LinuxTips** — Unit 4 (Terraform workflow)
- Official CLI docs: https://developer.hashicorp.com/terraform/cli/commands

---

## Week 3 — HCL Configuration: Resources, Variables, Outputs, Data Sources

**Exam Objectives:** 4a–4c (resources, data blocks, variables, outputs, cross-references)

### Concepts to Master
- `resource` block syntax and behavior
- Resource addressing: `<type>.<name>`, `module.<name>.<type>.<name>`
- Meta-arguments: `depends_on`, `count`, `for_each`, `lifecycle`
- `data` block — query existing infrastructure without managing it
- Input variables: types, defaults, validation rules, sensitive flag
- Variable precedence (env vars, tfvars, CLI flags)
- `terraform.tfvars` and `*.auto.tfvars` — automatic loading
- Output values: `value`, `description`, `sensitive`
- Cross-resource references: `resource_type.name.attribute`
- Local values: `locals {}` block

### Hands-on Labs (this repo)
```bash
# Lab 1: Read existing resources and understand attributes
cat aws/main.tf          # EC2 + S3 resources
cat aws/variables.tf     # input variable definitions
cat aws/outputs.tf       # output value definitions

# Lab 2: Understand variable types
cat kubernetes/variables.tf   # complex types: string, number, bool, list, map, object

# Lab 3: Variable precedence — override without editing files
cd local/
terraform apply -var="tomcat_port=9090"

# Lab 4: Environment variable override
export TF_VAR_tomcat_port=9090
terraform plan
unset TF_VAR_tomcat_port

# Lab 5: Data sources (if AWS configured)
cat aws/main.tf   # look for any data sources

# Lab 6: Create a local values exercise
# Add to local/main.tf: locals { full_name = "lab-${var.environment}" }
# Reference: name = local.full_name

# Lab 7: Count meta-argument
# Add count = 2 to a docker_container resource, observe plan output
```

### Key Questions to Answer
- What is the variable precedence order? (default < file < env < CLI)
- What does `sensitive = true` do to an output? (hides in terminal, still in state)
- How do you reference an attribute from another resource?
- What is a `data` source vs a `resource`?
- When should you use `locals` vs `variables`?

### Resources This Week
- **Udemy (StackSimplify)** — Sections 4, 5, 6 (Variables, Resources, Datasources)
- **LinkedIn Learning** — Chapter 5 (Variables and Outputs)
- Official: https://developer.hashicorp.com/terraform/language/resources
- Official: https://developer.hashicorp.com/terraform/language/values

---

## Week 4 — Advanced HCL: Functions, Expressions, Lifecycle, Sensitive Data

**Exam Objectives:** 4d–4h (complex types, expressions, functions, lifecycle, validation, secrets)

### Concepts to Master
- Complex types: `list`, `map`, `set`, `object`, `tuple`
- Built-in functions: `toset()`, `tolist()`, `length()`, `join()`, `format()`, `lookup()`, `merge()`, `flatten()`
- `for` expressions: `[for item in list : item.name]`
- `for_each` with maps and sets
- Dynamic blocks: `dynamic "block_name" { ... }`
- Conditional expressions: `condition ? true_val : false_val`
- `lifecycle` meta-argument: `create_before_destroy`, `prevent_destroy`, `ignore_changes`, `replace_triggered_by`
- Custom validation rules: `validation { condition = ... error_message = ... }`
- `check` blocks for post-apply validation
- Sensitive variables and how they appear in state
- Vault provider for secrets injection

### Hands-on Labs (this repo)
```bash
# Lab 1: Explore complex variable types
cat kubernetes/variables.tf   # webapp_resources is an object type

# Lab 2: for_each with map
# In local/main.tf — note how containers are created

# Lab 3: lifecycle blocks
# Review aws/main.tf for lifecycle rules
# Add prevent_destroy to a local container resource

# Lab 4: Built-in functions in terraform console
cd local/
terraform console
# Try these:
> length(["a", "b", "c"])
> upper("hello")
> format("Hello, %s!", "world")
> toset(["a", "b", "a"])    # deduplicates
> join(", ", ["one", "two", "three"])
> lookup({a="1", b="2"}, "a", "default")
> merge({a=1}, {b=2})
exit

# Lab 5: Sensitive variable
# Add sensitive = true to a variable, observe plan output hides value
```

### Key Questions to Answer
- What is `create_before_destroy` used for?
- What does `ignore_changes = [tags]` do?
- What does `prevent_destroy = true` protect against?
- How does `for_each` differ from `count`?
- What happens to sensitive values in the state file?

### Resources This Week
- **Udemy (StackSimplify)** — Sections 10–13 (Meta-arguments), Section 15 (Expressions), Section 50 (Dynamic Blocks)
- **LinuxTips** — Unit 6 (Advanced HCL)
- Official: https://developer.hashicorp.com/terraform/language/functions
- Official: https://developer.hashicorp.com/terraform/language/meta-arguments/lifecycle

---

## Week 5 — State Management

**Exam Objectives:** 6 (all sub-objectives: local/remote backend, locking, drift, refactoring)

### Concepts to Master
- What Terraform state is and why it exists
- State file format (JSON) — what it contains
- Local backend (default): `terraform.tfstate`
- Remote backends: S3 + DynamoDB (AWS), Azure Blob, GCS, HCP Terraform
- State locking: prevents concurrent operations from corrupting state
- `terraform state list` — list all resources in state
- `terraform state show <resource>` — show resource details
- `terraform state mv` — rename/move resources in state
- `terraform state rm` — remove resource from state (does not destroy)
- `terraform state pull` / `terraform state push`
- `moved` block — declarative state refactoring (preferred over `state mv`)
- `removed` block — declarative state removal
- Drift detection: difference between real infra and state
- `terraform plan -refresh-only` — detect drift without changing infra
- `terraform apply -refresh-only` — sync state to match real infra

### Hands-on Labs (this repo)
```bash
# Lab 1: Inspect local state
cd local/
terraform apply   # ensure resources exist
cat terraform.tfstate | python3 -m json.tool | head -50

# Lab 2: State CLI commands
terraform state list
terraform state show docker_container.tomcat   # adjust resource name to actual
terraform state show docker_image.tomcat

# Lab 3: Remove from state and re-import
terraform state rm docker_image.tomcat
terraform plan    # now shows it needs to be created again
terraform apply   # re-adds to state (docker image already exists, quick)

# Lab 4: Remote state with S3 backend (if AWS configured)
# Add backend "s3" block to aws/providers.tf:
# terraform {
#   backend "s3" {
#     bucket         = "my-terraform-state-bucket"
#     key            = "learning-terraform/aws/terraform.tfstate"
#     region         = "us-east-1"
#     dynamodb_table = "terraform-state-lock"
#   }
# }
# terraform init -migrate-state

# Lab 5: Drift simulation
# Manually change a resource outside Terraform
# Then: terraform plan -refresh-only
```

### Key Questions to Answer
- What does the state file store? (resource attributes, metadata, dependencies)
- What is state locking and which backends support it?
- What is the difference between `state rm` and `destroy`?
- What does `moved` block do differently from `terraform state mv`?
- When would you use `plan -refresh-only`?

### Resources This Week
- **Udemy (StackSimplify)** — Section 7 (Terraform State), Section 30 (State Commands)
- **LinkedIn Learning** — Chapter 6 (State)
- Official: https://developer.hashicorp.com/terraform/language/state
- Official: https://developer.hashicorp.com/terraform/language/state/backends

---

## Week 6 — Modules

**Exam Objectives:** 5 (all sub-objectives: sourcing, variable scope, versioning, registry vs local)

### Concepts to Master
- What modules are: reusable configuration packages
- Root module vs child modules
- Module sources: local path, public registry, GitHub, private registry
- Registry module format: `<namespace>/<module>/<provider>` (e.g. `hashicorp/consul/aws`)
- Module versioning: `version = "~> 3.0"` in module block
- Module inputs: passing variables to a module (required and optional)
- Module outputs: consuming a module's outputs in the parent
- Variable scope: module variables are private (not accessible unless exported)
- Module best practices: standard structure (`main.tf`, `variables.tf`, `outputs.tf`, `README.md`)

### Hands-on Labs (this repo)
```bash
# Lab 1: Examine the local modules in this repo
cat kubernetes/main.tf         # calls two local modules
cat kubernetes/modules/webapp/main.tf       # webapp module
cat kubernetes/modules/webapp/variables.tf  # module inputs
cat kubernetes/modules/webapp/outputs.tf    # module outputs
cat kubernetes/modules/storage/main.tf      # storage module

# Lab 2: Trace a variable from root to module
# kubernetes/variables.tf → webapp_replicas
# kubernetes/main.tf → module.webapp { replicas = var.webapp_replicas }
# kubernetes/modules/webapp/variables.tf → var.replicas
# kubernetes/modules/webapp/main.tf → spec { replicas = var.replicas }

# Lab 3: Trace an output from module to root
# kubernetes/modules/webapp/outputs.tf → service_name
# kubernetes/outputs.tf → module.webapp.service_name

# Lab 4: Use a public registry module (local exercise)
# Create a test dir and use a registry module:
mkdir /tmp/module-test && cd /tmp/module-test
cat > main.tf << 'EOF'
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"
  name = "test-vpc"
  cidr = "10.0.0.0/16"
}
EOF
terraform init    # downloads from registry
ls .terraform/modules/
```

### Key Questions to Answer
- What is the difference between a root module and a child module?
- How do you pass a variable to a module?
- How do you consume a module's output?
- What is the format for a Terraform Registry module source?
- Are module variables accessible outside the module without explicit outputs?
- What does `terraform init` do for modules?

### Resources This Week
- **Udemy (StackSimplify)** — Sections 37–41 (Modules: public, local, private registry)
- **LinkedIn Learning** — Chapter 7 (Modules)
- **LinuxTips** — Unit on Modules
- This repo: `kubernetes/modules/` — complete example
- Official: https://developer.hashicorp.com/terraform/language/modules

---

## Week 7 — Maintain Infrastructure + Troubleshoot

**Exam Objectives:** 7 (import, state inspect, verbose logging)

### Concepts to Master
- `terraform import` — bring existing infrastructure under Terraform management
- The new declarative `import` block (Terraform 1.5+)
- `terraform show` — show current state or a saved plan
- `terraform state list` — list all managed resources
- `terraform refresh` — deprecated; use `plan/apply -refresh-only`
- `TF_LOG` environment variable: `TRACE`, `DEBUG`, `INFO`, `WARN`, `ERROR`
- `TF_LOG_PATH` — write logs to file
- Common errors and how to troubleshoot:
  - Provider authentication errors
  - State lock errors
  - Resource already exists errors
  - Dependency cycle errors
- `terraform taint` — deprecated; use `-replace` flag
- `terraform apply -replace=resource.name` — force recreate

### Hands-on Labs (this repo)
```bash
# Lab 1: Import existing Docker resource
cd local/
terraform apply   # ensure resources exist

# Manually create a Docker container outside Terraform
docker run -d --name manual-nginx nginx:alpine

# Import it into state:
# First add a resource block in main.tf:
# resource "docker_container" "imported" { name = "manual-nginx" image = docker_image.nginx.image_id }
# Then: terraform import docker_container.imported manual-nginx
# terraform state show docker_container.imported

# Lab 2: Enable verbose logging
TF_LOG=DEBUG terraform plan 2>&1 | head -50
TF_LOG=INFO TF_LOG_PATH=/tmp/tf-debug.log terraform apply
cat /tmp/tf-debug.log | head -30

# Lab 3: Inspect state
terraform show
terraform state list
terraform state show docker_container.tomcat

# Lab 4: Force replace (recreate) a resource
terraform apply -replace=docker_container.tomcat

# Lab 5: terraform console for troubleshooting expressions
terraform console
> 2 + 2
> "hello ${upper("world")}"
```

### Key Questions to Answer
- What does `terraform import` do to the state file?
- Does `terraform import` generate configuration automatically? (No — you write it first)
- What `TF_LOG` level is most verbose? (`TRACE`)
- What replaced `terraform taint`?
- When would you use `terraform show`?

### Resources This Week
- **Udemy (StackSimplify)** — Sections 46 (Import), 47 (Graph), 16 (Debug)
- Official: https://developer.hashicorp.com/terraform/cli/import
- Official: https://developer.hashicorp.com/terraform/internals/debugging

---

## Week 8 — HCP Terraform + Final Review + Practice Exam

**Exam Objectives:** 8 (all sub-objectives: workspaces, projects, VCS/CLI workflow, policies, drift)

### Concepts to Master
- What HCP Terraform is and its role (remote state, remote execution, collaboration)
- HCP Terraform vs Terraform Enterprise
- Workspaces in HCP Terraform (different from CLI workspaces)
- Projects — organizing multiple workspaces
- VCS-driven workflow — auto plan/apply on git push
- CLI-driven workflow — `terraform login` + `cloud {}` block
- Variable sets — share variables across workspaces
- Run triggers — workspace A triggers workspace B
- Remote state data source: `terraform_remote_state`
- Policy enforcement: OPA (Open Policy Agent) policies
- Drift detection in HCP Terraform (continuous health assessment)
- `terraform login` / `terraform logout`
- Migrating local state to HCP Terraform
- Private module registry

### Hands-on Labs (HCP Terraform — free tier)
```bash
# Lab 1: Login to HCP Terraform
terraform login
# Opens browser → authorize → creates ~/.terraform.d/credentials.tfrc.json

# Lab 2: Add cloud block to local/ module
# Add to local/providers.tf:
# terraform {
#   cloud {
#     organization = "your-org-name"
#     workspaces { name = "learning-terraform-local" }
#   }
# }
terraform init   # migrates state to HCP Terraform

# Lab 3: Run plan from CLI (executes remotely)
terraform plan   # runs in HCP Terraform

# Lab 4: Explore HCP Terraform UI
# - Create a workspace from the UI
# - Set variables in workspace UI
# - Connect to GitHub (VCS-driven workflow)
# - Enable drift detection on workspace

# Lab 5: Variable sets
# Create a variable set in HCP Terraform with AWS credentials
# Assign to multiple workspaces
```

### Final Review Checklist
- [ ] Completed all 8 objective study sections
- [ ] All `local/` hands-on labs done
- [ ] Reviewed official exam content list: https://developer.hashicorp.com/terraform/tutorials/certification-004/associate-review-004
- [ ] Completed practice questions from Udemy StackSimplify course (Section 17)
- [ ] Reviewed official sample questions: https://developer.hashicorp.com/terraform/tutorials/certification-004/associate-questions-004
- [ ] Reviewed cheatsheets in `cert-roadmap/cheatsheets/`
- [ ] Scored 80%+ on 2 practice exams

### Resources This Week
- **Udemy (StackSimplify)** — Sections 39–45 (Terraform Cloud, Sentinel, VCS/CLI workflows)
- Official: https://developer.hashicorp.com/terraform/cloud-docs
- Official Get Started collection: https://developer.hashicorp.com/terraform/tutorials/cloud-get-started

---

## Exam Registration

1. Go to: https://developer.hashicorp.com/certifications/infrastructure-automation
2. Click **"Terraform Associate (004)"**
3. Register through PSI Online Proctoring (online exam, from home)
4. Schedule at least 48 hours in advance

**Retake policy:** Must wait 24 hours after first failed attempt; 14 days before third attempt.

---

## Scoring Breakdown (approximate weight by objective)

| Objective | Topics | Weight |
|-----------|--------|--------|
| 1 | IaC concepts | Low (~5%) |
| 2 | Fundamentals | Medium (~10%) |
| 3 | Core workflow | High (~15%) |
| 4 | Configuration | High (~25%) |
| 5 | Modules | Medium (~10%) |
| 6 | State management | High (~20%) |
| 7 | Maintenance | Medium (~10%) |
| 8 | HCP Terraform | Medium (~5%) |

Focus most time on **Objectives 3, 4, and 6** — they carry the most weight.
