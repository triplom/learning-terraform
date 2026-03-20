# Objective 4: Use Terraform Outside the Core Workflow (Configuration Language)

**Exam Weight:** ~22%
**Official Reference:** https://developer.hashicorp.com/terraform/tutorials/certification-004/associate-review-004

---

## 4.1 HCL Fundamentals

HashiCorp Configuration Language (HCL) is the language used in `.tf` files.

### Basic Syntax
```hcl
# Block type: resource, variable, output, data, module, locals, terraform, provider
<BLOCK_TYPE> "<BLOCK_LABEL>" "<BLOCK_LABEL>" {
  # Arguments
  argument_name = value

  # Nested block
  nested_block {
    key = value
  }
}
```

### Data Types
| Type | Example |
|------|---------|
| `string` | `"hello"` |
| `number` | `42`, `3.14` |
| `bool` | `true`, `false` |
| `list(type)` | `["a", "b", "c"]` |
| `set(type)` | `toset(["a", "b"])` |
| `map(type)` | `{ key = "value" }` |
| `object({...})` | `{ name = string, age = number }` |
| `tuple([...])` | `["string", 42, true]` |
| `any` | Any type (dynamic) |

### String Interpolation and Heredoc
```hcl
# Interpolation
name = "Hello, ${var.username}!"

# Heredoc (multi-line string)
user_data = <<-EOT
  #!/bin/bash
  echo "Hello ${var.name}"
  apt-get update
EOT
```

---

## 4.2 Resources

Resources are the primary element of Terraform configuration — they define infrastructure objects.

```hcl
resource "aws_instance" "web" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = var.instance_type

  tags = {
    Name        = "WebServer"
    Environment = var.environment
  }
}
```

### Resource Addressing
```
<resource_type>.<resource_name>           # e.g., aws_instance.web
module.<module_name>.<resource_type>.<name>  # e.g., module.vpc.aws_subnet.public
```

### Resource Dependencies
```hcl
# Implicit dependency (via reference)
resource "aws_instance" "web" {
  subnet_id = aws_subnet.main.id   # Terraform knows to create subnet first
}

# Explicit dependency (when no reference exists)
resource "aws_instance" "web" {
  depends_on = [aws_iam_role_policy.allow_s3]
}
```

---

## 4.3 Data Sources

Data sources allow Terraform to read existing infrastructure that is NOT managed by the current config.

```hcl
# Read an existing AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]  # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-*-22.04-amd64-server-*"]
  }
}

# Use the data source
resource "aws_instance" "web" {
  ami = data.aws_ami.ubuntu.id    # data.<type>.<name>.<attribute>
}
```

**Data source vs Resource:**
| | Resource (`resource`) | Data Source (`data`) |
|--|----------------------|---------------------|
| Creates infrastructure? | Yes | No |
| Manages lifecycle? | Yes | No |
| Shows in plan as? | `+` or `~` | `<=` (read) |
| In state file? | Yes | Yes (cached) |

---

## 4.4 Variables

### Input Variables (`variable`)
```hcl
variable "instance_type" {
  type        = string
  description = "EC2 instance type"
  default     = "t3.micro"
  
  validation {
    condition     = contains(["t3.micro", "t3.small"], var.instance_type)
    error_message = "Must be t3.micro or t3.small."
  }
}
```

### Variable Precedence (lowest to highest)
1. Default value in `variable` block
2. `terraform.tfvars` file
3. `*.auto.tfvars` files (alphabetical order)
4. `-var-file` flag
5. `-var` flag
6. `TF_VAR_<name>` environment variable (highest priority)

> **Exam tip:** Environment variables `TF_VAR_name` have the HIGHEST precedence — they override everything else.

### Variable Types and Validation
```hcl
variable "port" {
  type    = number
  default = 8080

  validation {
    condition     = var.port > 0 && var.port < 65536
    error_message = "Port must be between 1 and 65535."
  }
}

variable "tags" {
  type = map(string)
  default = {
    Environment = "dev"
  }
}

variable "allowed_cidr" {
  type = list(string)
  default = ["10.0.0.0/8"]
}
```

---

## 4.5 Output Values

Outputs expose values after apply — for user display, module consumption, or state queries.

```hcl
output "instance_ip" {
  description = "Public IP of the web instance"
  value       = aws_instance.web.public_ip
  sensitive   = false
}

output "db_password" {
  description = "Database password"
  value       = random_password.db.result
  sensitive   = true   # Redacts from CLI output
}
```

### Accessing Outputs
```bash
terraform output                 # Show all outputs
terraform output instance_ip     # Specific output
terraform output -json           # JSON (for scripting)
terraform output -raw instance_ip  # Raw string (no quotes)
```

> **Exam tip:** `sensitive = true` hides output from `terraform output` CLI but the value IS still stored in state (in plaintext). State must be secured separately.

---

## 4.6 Local Values (`locals`)

Locals define reusable expressions within a module — avoids repetition.

```hcl
locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
  
  name_prefix = "${var.project_name}-${var.environment}"
}

resource "aws_instance" "web" {
  tags = local.common_tags  # Reference with local.<name>
}
```

**When to use locals vs variables:**
- `variable` — input from outside (user/CI/other modules)
- `local` — internal computed values, avoids repeating expressions

---

## 4.7 Built-in Functions

Terraform has many built-in functions (no custom functions in HCL — this is a common exam trap).

### String Functions
```hcl
upper("hello")           # "HELLO"
lower("HELLO")           # "hello"
format("Hello, %s!", var.name)
trimspace("  hello  ")   # "hello"
split(",", "a,b,c")      # ["a", "b", "c"]
join("-", ["a", "b"])    # "a-b"
replace("hello", "l", "r")  # "herro"
```

### Numeric Functions
```hcl
max(1, 2, 3)     # 3
min(1, 2, 3)     # 1
ceil(1.2)        # 2
floor(1.8)       # 1
abs(-5)          # 5
```

### Collection Functions
```hcl
length(["a","b","c"])       # 3
toset(["a","b","a"])        # {"a","b"} (deduplicates)
tolist(toset(["b","a"]))    # ["a","b"]
flatten([["a","b"],["c"]])  # ["a","b","c"]
merge({a=1},{b=2})          # {a=1,b=2}
keys({a=1,b=2})             # ["a","b"]
values({a=1,b=2})           # [1,2]
contains(["a","b"], "a")    # true
lookup({a=1,b=2}, "a", 0)   # 1 (0 is default)
element(["a","b","c"], 1)   # "b"
```

### Type Conversion Functions
```hcl
tostring(42)        # "42"
tonumber("42")      # 42
tobool("true")      # true
tolist(["a","b"])   # list
tomap({a="1"})      # map
```

### Filesystem and Encoding
```hcl
file("path/to/file.txt")      # Read file contents as string
filebase64("path/file.zip")   # Base64 encode file contents
templatefile("tmpl.tpl", {    # Render template with variables
  name = var.name
})
jsonencode({key = "value"})   # Encode to JSON string
jsondecode("{\"key\":\"val\"}") # Parse JSON string
base64encode("hello")         # "aGVsbG8="
base64decode("aGVsbG8=")      # "hello"
```

> **Exam tip:** Terraform does NOT support user-defined functions. You cannot write `function foo() {...}` in HCL.

---

## 4.8 Resource Lifecycle

The `lifecycle` meta-argument controls how Terraform handles resource creation, updates, and deletion.

```hcl
resource "aws_instance" "web" {
  ami           = var.ami_id
  instance_type = "t3.micro"

  lifecycle {
    create_before_destroy = true   # Create replacement before destroying old
    prevent_destroy       = true   # Block any destroy operation
    ignore_changes        = [tags] # Ignore changes to specific attributes
    replace_triggered_by  = [var.image_id]  # Trigger replacement when var changes
  }
}
```

### Lifecycle Arguments
| Argument | Effect | Use Case |
|----------|--------|---------|
| `create_before_destroy = true` | New resource created before old is destroyed | Zero-downtime replacement |
| `prevent_destroy = true` | Error if plan includes destroy | Protect databases, critical resources |
| `ignore_changes = [attr]` | Don't track changes to listed attributes | Resources modified outside Terraform |
| `replace_triggered_by = [...]` | Replace when listed objects change | Force re-deploy when config changes |

> **Exam tip:** `prevent_destroy = true` prevents `terraform apply` from destroying the resource, but does NOT prevent `terraform state rm` (manual state removal). It is a policy guard, not a hard lock.

---

## 4.9 Sensitive Data in Configuration

```hcl
# Mark variable as sensitive
variable "db_password" {
  type      = string
  sensitive = true
}

# Mark output as sensitive
output "connection_string" {
  value     = "postgres://user:${var.db_password}@${aws_db_instance.main.endpoint}/db"
  sensitive = true
}
```

### Sensitive Data Rules
- Sensitive variables are redacted in `terraform plan` and `apply` output
- Values ARE stored in state file (unencrypted by default)
- Secure your state file (use encrypted remote backend)
- Use secret managers (AWS Secrets Manager, Vault) for runtime injection

---

## 4.10 Meta-Arguments

Meta-arguments apply to any resource type:

| Meta-Argument | Description |
|---------------|-------------|
| `depends_on` | Explicit dependency declaration |
| `count` | Create multiple instances by number |
| `for_each` | Create multiple instances by map/set |
| `provider` | Use a specific provider alias |
| `lifecycle` | Control create/update/delete behavior |

### `count`
```hcl
resource "aws_instance" "web" {
  count         = 3
  instance_type = "t3.micro"
  tags = {
    Name = "web-${count.index}"  # 0, 1, 2
  }
}
# Access: aws_instance.web[0].id, aws_instance.web[1].id
```

### `for_each`
```hcl
resource "aws_instance" "web" {
  for_each      = toset(["app", "db", "cache"])
  instance_type = "t3.micro"
  tags = {
    Name = each.key  # "app", "db", "cache"
  }
}
# Access: aws_instance.web["app"].id
```

**`count` vs `for_each`:**
| | `count` | `for_each` |
|--|---------|-----------|
| Index | Integer (0, 1, 2...) | String key |
| Removal behavior | Renumbers remaining resources (risky) | Only removes specific key (safe) |
| Input | Number | Map or Set of strings |
| Best for | Identical resources | Resources with distinct identities |

---

## Practice Questions

**Q1:** What is the order of variable precedence in Terraform (highest to lowest)?
- **A) TF_VAR env var > -var flag > -var-file flag > *.auto.tfvars > terraform.tfvars > default** ✓
- B) default > terraform.tfvars > -var flag > TF_VAR env var
- C) -var flag > TF_VAR env var > terraform.tfvars > default
- D) terraform.tfvars > -var flag > default > TF_VAR env var

**Q2:** Which lifecycle argument would you use to ensure zero-downtime when a resource must be replaced?
- A) `prevent_destroy = true`
- **B) `create_before_destroy = true`** ✓
- C) `ignore_changes = [all]`
- D) `replace_triggered_by = [null_resource.always]`

**Q3:** An output is marked `sensitive = true`. What is TRUE about this output?
- A) The value is encrypted in the state file
- B) The value is never stored anywhere
- **C) The value is stored in state but redacted from CLI output** ✓
- D) The value cannot be used by other modules

**Q4:** You have a resource that is managed by both Terraform and an external autoscaling system that modifies tags. Which lifecycle setting prevents Terraform from reverting the autoscaler's tag changes?
- A) `create_before_destroy = true`
- B) `prevent_destroy = true`
- **C) `ignore_changes = [tags]`** ✓
- D) `replace_triggered_by = [aws_autoscaling_group.main]`

**Q5:** Can you define custom functions in HCL?
- **A) No — Terraform does not support user-defined functions** ✓
- B) Yes — using the `function` block
- C) Yes — using `locals` with lambda expressions
- D) Only in Terraform 1.x and above

**Q6:** What is the difference between `count` and `for_each`?
- A) `count` supports string keys; `for_each` supports integers
- B) `for_each` is deprecated in Terraform 1.x
- **C) Removing an item from `count` renumbers indexes, potentially causing unintended resource replacements; `for_each` uses stable string keys** ✓
- D) They are functionally identical

---

## Lab Reference

**Repo files to review:**
- `/aws/variables.tf` — variable definitions with types and defaults
- `/aws/outputs.tf` — output blocks
- `/aws/main.tf` — resource blocks with references and dependencies
- `/kubernetes/modules/webapp/` — locals, variables, resources together
- `/local/main.tf` — data sources, resources, count/for_each examples

```bash
# From /home/triplom/terraform-cert-work/local/
terraform console   # Interactive HCL/function testing

# Inside terraform console:
> upper("hello")
> length(["a", "b", "c"])
> merge({a=1}, {b=2})
> format("Name: %s-%d", "web", 1)
```

---

*Previous: [Objective 3 — Core Workflow](./03-core-workflow.md)*
*Next: [Objective 5 — Modules](./05-modules.md)*
