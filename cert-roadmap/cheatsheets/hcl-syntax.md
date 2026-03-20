# HCL Syntax Cheatsheet

Quick reference for HashiCorp Configuration Language (HCL) patterns used in Terraform.

---

## File Structure

```
project/
├── main.tf          # Primary resources
├── variables.tf     # Variable declarations
├── outputs.tf       # Output values
├── providers.tf     # Provider configurations
├── versions.tf      # terraform{} block with required_version/providers
├── locals.tf        # Local values
└── terraform.tfvars # Variable values (not committed if secrets)
```

---

## Block Types

```hcl
# Provider configuration
provider "aws" {
  region = "us-east-1"
  alias  = "primary"    # Optional: named provider
}

# Resource
resource "aws_instance" "web" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t3.micro"
}

# Data source
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]
}

# Variable declaration
variable "instance_type" {
  type        = string
  description = "EC2 instance type"
  default     = "t3.micro"
}

# Output
output "instance_ip" {
  value       = aws_instance.web.public_ip
  description = "Public IP"
  sensitive   = false
}

# Local value
locals {
  common_tags = {
    Environment = var.environment
    Project     = var.project
  }
}

# Module call
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"
  name    = var.vpc_name
}

# Terraform settings block
terraform {
  required_version = ">= 1.0, < 2.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket = "my-tf-state"
    key    = "prod/terraform.tfstate"
    region = "us-east-1"
  }
}
```

---

## Data Types

```hcl
# Primitives
string_val  = "hello world"
number_val  = 42
float_val   = 3.14
bool_val    = true

# List (ordered, allows duplicates)
list_val    = ["a", "b", "c"]

# Set (unordered, no duplicates)
set_val     = toset(["a", "b", "c"])

# Map (key-value pairs, same value type)
map_val     = {
  key1 = "value1"
  key2 = "value2"
}

# Object (key-value pairs, different value types)
object_val  = {
  name    = "web"
  port    = 80
  enabled = true
}

# Tuple (ordered list with mixed types)
tuple_val   = ["string", 42, true]

# Null
null_val    = null
```

---

## Variable Declarations

```hcl
variable "region" {
  type        = string
  description = "AWS region"
  default     = "us-east-1"
}

variable "instance_count" {
  type    = number
  default = 1
}

variable "enable_monitoring" {
  type    = bool
  default = false
}

variable "allowed_ports" {
  type    = list(number)
  default = [80, 443, 8080]
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "server_config" {
  type = object({
    instance_type = string
    ami_id        = string
    root_size_gb  = number
  })
}

# Sensitive variable
variable "db_password" {
  type      = string
  sensitive = true
}

# Variable with validation
variable "environment" {
  type    = string
  default = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Must be dev, staging, or prod."
  }
}
```

---

## References and Expressions

```hcl
# Resource attribute reference
aws_instance.web.id
aws_instance.web.public_ip

# Variable reference
var.instance_type
var.tags["Environment"]

# Local reference
local.common_tags
local.name_prefix

# Data source reference
data.aws_ami.ubuntu.id
data.aws_vpc.main.cidr_block

# Module output reference
module.vpc.vpc_id
module.vpc.public_subnets[0]

# String interpolation
name = "web-${var.environment}"
name = "${var.project}-${var.environment}-server"

# Conditional expression (ternary)
instance_type = var.environment == "prod" ? "t3.large" : "t3.micro"

# For expression (list)
upper_names = [for name in var.names : upper(name)]

# For expression (map)
upper_map = {for k, v in var.tags : k => upper(v)}

# Splat expression
all_instance_ids = aws_instance.web[*].id

# Dynamic block
dynamic "ingress" {
  for_each = var.ingress_rules
  content {
    from_port   = ingress.value.from_port
    to_port     = ingress.value.to_port
    protocol    = ingress.value.protocol
    cidr_blocks = ingress.value.cidr_blocks
  }
}
```

---

## Meta-Arguments

```hcl
resource "aws_instance" "web" {
  count = 3
  # aws_instance.web[0], web[1], web[2]
  # count.index = 0, 1, 2
}

resource "aws_instance" "web" {
  for_each = toset(["app", "db", "cache"])
  # aws_instance.web["app"], web["db"], web["cache"]
  # each.key, each.value
}

resource "aws_instance" "web" {
  for_each = {
    app   = "t3.micro"
    db    = "t3.large"
  }
  instance_type = each.value  # each.key = "app"/"db"
}

resource "aws_instance" "web" {
  depends_on = [aws_iam_role_policy.web]   # Explicit dependency
}

resource "aws_instance" "web" {
  provider = aws.secondary   # Use named provider alias
}

resource "aws_instance" "web" {
  lifecycle {
    create_before_destroy = true
    prevent_destroy       = false
    ignore_changes        = [tags, user_data]
    replace_triggered_by  = [var.ami_id]
  }
}
```

---

## String Templates and Heredoc

```hcl
# Simple interpolation
name = "Hello, ${var.username}!"

# Heredoc (multi-line string)
user_data = <<EOT
#!/bin/bash
echo "Server: ${var.server_name}"
apt-get update
EOT

# Heredoc with stripped indentation (<<-)
user_data = <<-EOT
  #!/bin/bash
  echo "Hello"
EOT

# Template directive (conditionals in strings)
user_data = <<-EOT
  #!/bin/bash
  %{ if var.enable_monitoring }
  /opt/setup-monitoring.sh
  %{ endif }
EOT

# Template for loop
hosts = <<-EOT
  %{ for ip in var.ips }
  ${ip}
  %{ endfor }
EOT
```

---

## Common Built-in Functions

```hcl
# String
upper("hello")              # "HELLO"
lower("HELLO")              # "hello"
format("%s-%d", "web", 1)  # "web-1"
join(",", ["a","b","c"])   # "a,b,c"
split(",", "a,b,c")        # ["a","b","c"]
trimspace("  hi  ")        # "hi"
replace("hello", "l", "r") # "herro"
substr("hello", 0, 3)      # "hel"
startswith("hello", "he")  # true
endswith("hello", "lo")    # true

# Numeric
max(1, 2, 3)    # 3
min(1, 2, 3)    # 1
ceil(1.1)       # 2
floor(1.9)      # 1
abs(-5)         # 5

# Collections
length(["a","b","c"])           # 3
toset(["a","b","a"])            # {"a","b"}
flatten([["a"],["b","c"]])      # ["a","b","c"]
merge({a=1},{b=2})              # {a=1,b=2}
keys({a=1,b=2})                 # ["a","b"]
values({a=1,b=2})               # [1,2]
contains(["a","b"], "a")        # true
lookup({a=1,b=2}, "a", 0)       # 1
element(["a","b","c"], 1)       # "b"
index(["a","b","c"], "b")       # 1
slice(["a","b","c","d"], 1, 3)  # ["b","c"]
compact(["a","","b"])           # ["a","b"]
distinct(["a","b","a"])         # ["a","b"]
chunklist(["a","b","c","d"], 2) # [["a","b"],["c","d"]]
zipmap(["a","b"],[1,2])         # {a=1,b=2}

# Type conversion
tostring(42)        # "42"
tonumber("42")      # 42
tobool("true")      # true
tolist(toset(["b","a"]))  # ["a","b"]

# Encoding / Filesystem
jsonencode({key = "val"})        # "{\"key\":\"val\"}"
jsondecode("{\"key\":\"val\"}")  # {key="val"}
base64encode("hello")            # "aGVsbG8="
base64decode("aGVsbG8=")         # "hello"
file("config.json")              # Read file as string
filebase64("file.zip")           # Read file as base64
templatefile("init.tpl", { name = var.name })  # Render template

# IP / CIDR
cidrsubnet("10.0.0.0/16", 8, 0)   # "10.0.0.0/24"
cidrhost("10.0.0.0/24", 5)        # "10.0.0.5"
```

---

## Version Constraint Operators

```hcl
version = "~> 5.0"       # >= 5.0.0, < 6.0.0
version = "~> 5.1"       # >= 5.1.0, < 5.2.0 (pin minor, allow patch)
version = ">= 5.0"       # 5.0 or higher
version = "<= 5.0"       # 5.0 or lower
version = "= 5.1.2"      # Exactly 5.1.2
version = "!= 5.0.0"     # Anything except 5.0.0
version = ">= 4.0, < 6.0" # Between 4 and 6 (exclusive)
```

---

## Moved and Removed Blocks

```hcl
# Rename a resource (Terraform 1.1+)
moved {
  from = aws_instance.old_name
  to   = aws_instance.new_name
}

# Rename within a module
moved {
  from = module.old_module.aws_instance.web
  to   = module.new_module.aws_instance.web
}

# Remove from state without destroying (Terraform 1.7+)
removed {
  from = aws_instance.old_web
  lifecycle {
    destroy = false
  }
}
```

---

## Import Block (Terraform 1.5+)

```hcl
import {
  to = aws_instance.web
  id = "i-0123456789abcdef0"
}

# Multiple imports
import {
  to = aws_s3_bucket.logs
  id = "my-log-bucket"
}

import {
  to = aws_s3_bucket.data
  id = "my-data-bucket"
}
```

---

*See also: [Terraform Commands](./terraform-commands.md) | [State Commands](./state-commands.md) | [Exam Tips](./exam-tips.md)*
