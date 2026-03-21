# Girus Warm-Up Exercises — Terraform Associate Cert

Practice Terraform and AWS fundamentals interactively in Girus **before** working through the cert labs.
Girus provides an in-browser terminal with guided tasks and automatic validation — no setup required.

> **Prerequisites:** Girus cluster running locally.
>
> ```bash
> # Verify Girus is running
> girus list clusters
> # Expected: girus cluster listed as active
>
> # Open the Girus web interface
> xdg-open http://localhost:8000
> ```

---

## Warm-Up Index

| Exercise | Girus Lab ID | Duration | Before Cert Lab |
|----------|-------------|----------|----------------|
| [WU-1: Terraform Fundamentals](#wu-1-terraform-fundamentals) | `terraform-fundamentos` | 30 min | Lab 1 (Core Workflow), Lab 2 (Variables) |
| [WU-2: AWS S3 Storage](#wu-2-aws-s3-storage) | `aws-s3-storage` | 25 min | Lab 3 (State — remote S3 backend) |
| [WU-3: AWS LocalStack + Terraform](#wu-3-aws-localstack--terraform) | `aws-localstack-terraform` | 30 min | Lab 1, Lab 3 |
| [WU-4: Terraform Provisioners and Modules](#wu-4-terraform-provisioners-and-modules) | `terraform-provisioners-modulos` | 30 min | Lab 4 (Modules) |
| [WU-5: AWS DynamoDB NoSQL](#wu-5-aws-dynamodb-nosql) | `aws-dynamodb-nosql` | 20 min | Lab 3 (State locking — DynamoDB) |

**Total warm-up time:** ~2.5 hours

---

## WU-1: Terraform Fundamentals

**Girus Lab:** `terraform-fundamentos` | **Duration:** 30 min | **Prepares you for:** Cert Labs 1, 2

### Launch

```bash
girus lab start terraform-fundamentos
# Then open http://localhost:8000 and follow guided tasks in the browser terminal
```

### What You Will Practice

- The core Terraform workflow: `init` → `plan` → `apply` → `destroy`
- HCL syntax: `resource`, `variable`, `output`, `provider` blocks
- Provider configuration and `required_providers`
- Understanding state (`terraform.tfstate`)
- `terraform fmt`, `terraform validate`, `terraform console`

### Step-by-Step Guide (do these inside the Girus terminal)

**Step 1 — Create a working directory**

```bash
mkdir -p /tmp/tf-wu1
cd /tmp/tf-wu1
```

**Step 2 — Write a minimal Terraform configuration**

```bash
cat > main.tf <<'EOF'
terraform {
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }
}

variable "message" {
  description = "Message to write to file"
  type        = string
  default     = "Hello from Terraform!"
}

variable "filename" {
  description = "Output file name"
  type        = string
  default     = "/tmp/tf-output.txt"
}

resource "local_file" "hello" {
  content  = var.message
  filename = var.filename
}

output "file_path" {
  value       = local_file.hello.filename
  description = "Path to the created file"
}

output "file_content" {
  value = local_file.hello.content
}
EOF
```

**Step 3 — Format and validate**

```bash
terraform fmt
terraform validate
```

Expected output:

```
Success! The configuration is valid.
```

**Step 4 — Initialize**

```bash
terraform init
ls -la .terraform/
cat .terraform.lock.hcl
```

Expected output:

```
Initializing the backend...
Initializing provider plugins...
- Finding hashicorp/local versions matching "~> 2.0"...
- Installing hashicorp/local v2.x.x...
Terraform has been successfully initialized!
```

**Step 5 — Plan**

```bash
terraform plan
```

Expected output:

```
Terraform will perform the following actions:

  # local_file.hello will be created
  + resource "local_file" "hello" {
      + content              = "Hello from Terraform!"
      + filename             = "/tmp/tf-output.txt"
      + id                   = (known after apply)
    }

Plan: 1 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + file_content = "Hello from Terraform!"
  + file_path    = "/tmp/tf-output.txt"
```

**Step 6 — Apply**

```bash
terraform apply -auto-approve
```

Expected output:

```
local_file.hello: Creating...
local_file.hello: Creation complete after 0s [id=abc123...]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.

Outputs:

file_content = "Hello from Terraform!"
file_path = "/tmp/tf-output.txt"
```

```bash
# Verify the file was created
cat /tmp/tf-output.txt
terraform state list
terraform state show local_file.hello
```

**Step 7 — Variable override**

```bash
terraform apply -auto-approve \
  -var="message=Terraform Associate Cert 2026" \
  -var="filename=/tmp/tf-cert.txt"

cat /tmp/tf-cert.txt
```

Expected output:

```
Terraform Associate Cert 2026
```

**Step 8 — Terraform console**

```bash
terraform console
```

Inside the console:

```hcl
> var.message
"Hello from Terraform!"
> local_file.hello.filename
"/tmp/tf-cert.txt"
> upper("terraform")
"TERRAFORM"
> format("v%d.%d.%d", 1, 9, 0)
"v1.9.0"
> length(["a", "b", "c"])
3
> exit
```

**Step 9 — Destroy**

```bash
terraform destroy -auto-approve
terraform state list
```

Expected output:

```
local_file.hello: Destroying... [id=abc123...]
local_file.hello: Destruction complete after 0s

Destroy complete! Resources: 1 destroyed.

(empty — state list returns nothing)
```

### Validation Checklist

- [ ] `terraform init` downloads the `hashicorp/local` provider and creates `.terraform.lock.hcl`
- [ ] `terraform validate` passes without errors
- [ ] `terraform plan` shows exactly `1 to add` on first run
- [ ] `terraform apply` creates the file and shows outputs
- [ ] `-var` flag overrides the default variable value
- [ ] `terraform console` responds to HCL expressions
- [ ] `terraform destroy` removes the resource; `state list` is empty

### Common Errors

| Error | Cause | Fix |
|-------|-------|-----|
| `Error: Invalid provider configuration` | Provider block wrong | Check `source` format: `"hashicorp/local"` |
| `Error: Reference to undeclared resource` | Typo in resource name | Match name in `resource "type" "name"` exactly |
| Plan shows unexpected changes | Variable not overriding | Check `-var` syntax — no spaces around `=` |

### Cleanup

```bash
terraform destroy -auto-approve 2>/dev/null || true
cd /tmp && rm -rf tf-wu1 tf-output.txt tf-cert.txt
```

---

## WU-2: AWS S3 Storage

**Girus Lab:** `aws-s3-storage` | **Duration:** 25 min | **Prepares you for:** Cert Lab 3 (remote S3 backend for state)

### Launch

```bash
girus lab start aws-s3-storage
# Then open http://localhost:8000 and follow guided tasks in the browser terminal
```

### What You Will Practice

- Creating and configuring S3 buckets
- Bucket policies, versioning, and access control
- Using S3 as a Terraform remote state backend
- How Terraform uses DynamoDB + S3 for state locking

### Step-by-Step Guide (do these inside the Girus terminal)

> **Note:** The Girus `aws-s3-storage` lab uses LocalStack (local AWS simulator) — no real AWS account needed.

**Step 1 — Verify AWS CLI is configured for LocalStack**

```bash
aws --version
aws s3 ls --endpoint-url http://localhost:4566 2>/dev/null || \
  aws s3 ls  # Girus may pre-configure the endpoint
```

**Step 2 — Create an S3 bucket**

```bash
# Create bucket
aws s3 mb s3://terraform-state-lab \
  --endpoint-url http://localhost:4566 2>/dev/null || \
  aws s3 mb s3://terraform-state-lab

aws s3 ls
```

Expected output:

```
2026-03-21 10:00:00 terraform-state-lab
```

**Step 3 — Enable versioning (required for safe state backend)**

```bash
aws s3api put-bucket-versioning \
  --bucket terraform-state-lab \
  --versioning-configuration Status=Enabled \
  --endpoint-url http://localhost:4566 2>/dev/null || \
  aws s3api put-bucket-versioning \
    --bucket terraform-state-lab \
    --versioning-configuration Status=Enabled

# Verify
aws s3api get-bucket-versioning \
  --bucket terraform-state-lab \
  --endpoint-url http://localhost:4566 2>/dev/null || \
  aws s3api get-bucket-versioning --bucket terraform-state-lab
```

Expected output:

```json
{
    "Status": "Enabled"
}
```

**Step 4 — Upload and list objects**

```bash
echo "state test content" > /tmp/test-state.json
aws s3 cp /tmp/test-state.json s3://terraform-state-lab/test/

aws s3 ls s3://terraform-state-lab/test/
```

Expected output:

```
2026-03-21 10:00:01         19 test-state.json
```

**Step 5 — Understand S3 as Terraform backend**

```bash
# This is the S3 backend configuration pattern for Terraform
cat <<'EOF'
# terraform { backend "s3" { ... } } pattern:

terraform {
  backend "s3" {
    bucket         = "terraform-state-lab"
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"  # for state locking
  }
}
EOF
```

> **Cert exam note:** The S3 backend requires `bucket`, `key`, and `region`. Adding `dynamodb_table` enables state locking — prevents simultaneous `terraform apply` from multiple users.

**Step 6 — List and delete objects**

```bash
# List with versions
aws s3api list-object-versions \
  --bucket terraform-state-lab \
  --endpoint-url http://localhost:4566 2>/dev/null || \
  aws s3api list-object-versions --bucket terraform-state-lab

# Delete a specific object
aws s3 rm s3://terraform-state-lab/test/test-state.json

# Delete entire bucket (must be empty first)
aws s3 rb s3://terraform-state-lab --force
```

### Validation Checklist

- [ ] Can create an S3 bucket with `aws s3 mb`
- [ ] Can enable versioning with `aws s3api put-bucket-versioning`
- [ ] Can upload, list, and delete objects
- [ ] Understands the S3 backend Terraform block (bucket + key + region + encrypt)
- [ ] Understands why `dynamodb_table` is needed for state locking in team environments

### Common Errors

| Error | Cause | Fix |
|-------|-------|-----|
| `NoSuchBucket` | Bucket doesn't exist | `aws s3 mb s3://<bucket>` first |
| `BucketNotEmpty` | Can't delete a non-empty bucket | Use `--force` or empty bucket first |
| `NoCredentialsError` | AWS credentials not configured | `aws configure` or check Girus env |

---

## WU-3: AWS LocalStack + Terraform

**Girus Lab:** `aws-localstack-terraform` | **Duration:** 30 min | **Prepares you for:** Cert Labs 1, 3

### Launch

```bash
girus lab start aws-localstack-terraform
# Then open http://localhost:8000 and follow guided tasks in the browser terminal
```

### What You Will Practice

- Using Terraform with LocalStack (local AWS simulation)
- Creating AWS resources (S3, IAM) via Terraform without a real AWS account
- `terraform init`, `plan`, `apply`, `destroy` against LocalStack
- How the AWS provider configuration changes for LocalStack vs real AWS

### Step-by-Step Guide (do these inside the Girus terminal)

**Step 1 — Verify LocalStack is running**

```bash
curl -s http://localhost:4566/_localstack/health | python3 -m json.tool | grep -E '"s3"|"iam"|"running"'
```

Expected output:

```json
"s3": "running",
"iam": "running",
```

**Step 2 — Create a Terraform configuration targeting LocalStack**

```bash
mkdir -p /tmp/tf-localstack
cd /tmp/tf-localstack

cat > main.tf <<'EOF'
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region                      = "us-east-1"
  access_key                  = "test"
  secret_key                  = "test"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    s3  = "http://localhost:4566"
    iam = "http://localhost:4566"
  }
}

resource "aws_s3_bucket" "lab_bucket" {
  bucket = "terraform-localstack-lab"
}

resource "aws_s3_bucket_versioning" "lab_versioning" {
  bucket = aws_s3_bucket.lab_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

output "bucket_id" {
  value = aws_s3_bucket.lab_bucket.id
}

output "bucket_arn" {
  value = aws_s3_bucket.lab_bucket.arn
}
EOF
```

**Step 3 — Init, plan, apply**

```bash
terraform init
terraform validate
terraform plan
terraform apply -auto-approve
```

Expected output:

```
aws_s3_bucket.lab_bucket: Creating...
aws_s3_bucket.lab_bucket: Creation complete after 1s [id=terraform-localstack-lab]
aws_s3_bucket_versioning.lab_versioning: Creating...
aws_s3_bucket_versioning.lab_versioning: Creation complete after 0s

Apply complete! Resources: 2 added, 0 changed, 0 destroyed.

Outputs:
bucket_arn = "arn:aws:s3:::terraform-localstack-lab"
bucket_id  = "terraform-localstack-lab"
```

**Step 4 — Inspect state**

```bash
terraform state list
terraform state show aws_s3_bucket.lab_bucket
terraform output
```

**Step 5 — Verify via AWS CLI**

```bash
aws s3 ls --endpoint-url http://localhost:4566
aws s3api get-bucket-versioning \
  --bucket terraform-localstack-lab \
  --endpoint-url http://localhost:4566
```

**Step 6 — Destroy**

```bash
terraform destroy -auto-approve
aws s3 ls --endpoint-url http://localhost:4566  # bucket gone
```

### Validation Checklist

- [ ] LocalStack health endpoint shows S3 and IAM as "running"
- [ ] `terraform init` downloads the `hashicorp/aws` provider
- [ ] `terraform apply` creates the S3 bucket and versioning config in LocalStack
- [ ] `aws s3 ls --endpoint-url http://localhost:4566` confirms the bucket exists
- [ ] `terraform destroy` removes both resources; `terraform state list` is empty
- [ ] Understands the `endpoints {}` block for provider override (key for cert exam)

### Common Errors

| Error | Cause | Fix |
|-------|-------|-----|
| `Connection refused :4566` | LocalStack not running | `docker ps | grep localstack`; start if needed |
| `BucketAlreadyExists` | Bucket name conflict | Change `bucket = "..."` to a unique name |
| Plan shows no changes | Resources already exist | `terraform destroy` then re-apply |

### Cleanup

```bash
terraform destroy -auto-approve 2>/dev/null || true
cd /tmp && rm -rf tf-localstack
```

---

## WU-4: Terraform Provisioners and Modules

**Girus Lab:** `terraform-provisioners-modulos` | **Duration:** 30 min | **Prepares you for:** Cert Lab 4 (Modules)

### Launch

```bash
girus lab start terraform-provisioners-modulos
# Then open http://localhost:8000 and follow guided tasks in the browser terminal
```

### What You Will Practice

- Using `local-exec` and `remote-exec` provisioners
- When to use provisioners (last resort — not idiomatic Terraform)
- Creating and calling local Terraform modules
- Module `source`, `version`, variable passing, and output access

### Step-by-Step Guide (do these inside the Girus terminal)

**Step 1 — Understand provisioners**

```bash
mkdir -p /tmp/tf-provisioners
cd /tmp/tf-provisioners

cat > main.tf <<'EOF'
terraform {
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }
}

resource "local_file" "config" {
  content  = "app_version=1.0.0\nenv=lab"
  filename = "/tmp/tf-app.conf"

  provisioner "local-exec" {
    command = "echo 'Config file created at: ${self.filename}'"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "echo 'Config file will be destroyed: ${self.filename}'"
  }
}
EOF

terraform init
terraform apply -auto-approve
```

Expected output:

```
local_file.config: Creating...
local_file.config: Provisioning with 'local-exec'...
local_file.config (local-exec): Config file created at: /tmp/tf-app.conf
local_file.config: Creation complete after 0s
```

> **Cert exam note:** Provisioners run after resource creation. `when = destroy` runs before destruction. HashiCorp recommends avoiding provisioners when possible — use `user_data`, cloud-init, or configuration management tools instead.

**Step 2 — Create a reusable module**

```bash
mkdir -p /tmp/tf-modules/modules/file-writer
cd /tmp/tf-modules

# Module: modules/file-writer/
cat > modules/file-writer/variables.tf <<'EOF'
variable "content" {
  description = "Content to write"
  type        = string
}

variable "filename" {
  description = "File to create"
  type        = string
}

variable "label" {
  description = "Label for identification"
  type        = string
  default     = "default"
}
EOF

cat > modules/file-writer/main.tf <<'EOF'
terraform {
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }
}

resource "local_file" "output" {
  content  = var.content
  filename = var.filename
}
EOF

cat > modules/file-writer/outputs.tf <<'EOF'
output "path" {
  value       = local_file.output.filename
  description = "Path to the created file"
}

output "id" {
  value = local_file.output.id
}
EOF
```

**Step 3 — Call the module from root**

```bash
cat > main.tf <<'EOF'
terraform {
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }
}

module "app_config" {
  source   = "./modules/file-writer"
  content  = "APP_VERSION=2.0.0\nENV=production"
  filename = "/tmp/app.conf"
  label    = "production"
}

module "db_config" {
  source   = "./modules/file-writer"
  content  = "DB_HOST=localhost\nDB_PORT=5432"
  filename = "/tmp/db.conf"
  label    = "database"
}

output "app_config_path" {
  value = module.app_config.path
}

output "db_config_path" {
  value = module.db_config.path
}
EOF

terraform init
terraform plan
```

Expected plan output:

```
Terraform will perform the following actions:

  # module.app_config.local_file.output will be created
  + resource "local_file" "output" {
      + content  = "APP_VERSION=2.0.0\nENV=production"
      + filename = "/tmp/app.conf"
    }

  # module.db_config.local_file.output will be created
  + resource "local_file" "output" {
      + content  = "DB_HOST=localhost\nDB_PORT=5432"
      + filename = "/tmp/db.conf"
    }

Plan: 2 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + app_config_path = "/tmp/app.conf"
  + db_config_path  = "/tmp/db.conf"
```

```bash
terraform apply -auto-approve
terraform state list
```

Expected state:

```
module.app_config.local_file.output
module.db_config.local_file.output
```

> **Cert exam note:** Module resources appear in state as `module.<name>.<type>.<name>`. Module outputs are accessed as `module.<name>.<output>`.

**Step 4 — Module output access**

```bash
terraform output app_config_path
terraform output db_config_path
cat /tmp/app.conf
cat /tmp/db.conf
```

### Validation Checklist

- [ ] `local-exec` provisioner runs during `apply` and logs to stdout
- [ ] `when = destroy` provisioner fires during `terraform destroy`
- [ ] Module structure follows `variables.tf` / `main.tf` / `outputs.tf` pattern
- [ ] `terraform init` is required even for local modules
- [ ] `terraform state list` shows resources under `module.<name>.` prefix
- [ ] `module.<name>.<output>` syntax used in root to access module outputs

### Common Errors

| Error | Cause | Fix |
|-------|-------|-----|
| `Module not installed` | `terraform init` not run | `terraform init` in root directory |
| `Invalid value for module argument` | Missing required variable | Check module's `variables.tf` for vars without defaults |
| Provisioner not running | Resource not recreated | `terraform taint` resource or `terraform apply -replace` |

### Cleanup

```bash
terraform destroy -auto-approve 2>/dev/null || true
cd /tmp && rm -rf tf-provisioners tf-modules
```

---

## WU-5: AWS DynamoDB NoSQL

**Girus Lab:** `aws-dynamodb-nosql` | **Duration:** 20 min | **Prepares you for:** Cert Lab 3 (state locking)

### Launch

```bash
girus lab start aws-dynamodb-nosql
# Then open http://localhost:8000 and follow guided tasks in the browser terminal
```

### What You Will Practice

- Creating DynamoDB tables (on-demand and provisioned)
- Primary key (partition key + sort key) structure
- Putting, getting, and querying items
- Why DynamoDB is used for Terraform state locking

### Step-by-Step Guide (do these inside the Girus terminal)

> **Note:** Girus uses LocalStack or a pre-configured AWS environment.

**Step 1 — Create a DynamoDB table**

```bash
aws dynamodb create-table \
  --table-name terraform-locks \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --endpoint-url http://localhost:4566 2>/dev/null || \
aws dynamodb create-table \
  --table-name terraform-locks \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST
```

Expected output:

```json
{
    "TableDescription": {
        "TableName": "terraform-locks",
        "KeySchema": [{"AttributeName": "LockID", "KeyType": "HASH"}],
        "TableStatus": "ACTIVE",
        "BillingModeSummary": {"BillingMode": "PAY_PER_REQUEST"}
    }
}
```

> **Cert exam note:** Terraform's S3 backend uses DynamoDB with a **single primary key** named `LockID` of type `String`. This is the exact table structure required.

**Step 2 — Describe the table**

```bash
aws dynamodb describe-table \
  --table-name terraform-locks \
  --endpoint-url http://localhost:4566 2>/dev/null || \
aws dynamodb describe-table --table-name terraform-locks
```

**Step 3 — Put and get items (simulate Terraform lock)**

```bash
# Put a lock item (simulates terraform locking state)
aws dynamodb put-item \
  --table-name terraform-locks \
  --item '{"LockID": {"S": "prod/terraform.tfstate"}, "Info": {"S": "OperationID=abc123"}}' \
  --endpoint-url http://localhost:4566 2>/dev/null || \
aws dynamodb put-item \
  --table-name terraform-locks \
  --item '{"LockID": {"S": "prod/terraform.tfstate"}, "Info": {"S": "OperationID=abc123"}}'

# Get the lock item
aws dynamodb get-item \
  --table-name terraform-locks \
  --key '{"LockID": {"S": "prod/terraform.tfstate"}}' \
  --endpoint-url http://localhost:4566 2>/dev/null || \
aws dynamodb get-item \
  --table-name terraform-locks \
  --key '{"LockID": {"S": "prod/terraform.tfstate"}}'
```

Expected output:

```json
{
    "Item": {
        "LockID": {"S": "prod/terraform.tfstate"},
        "Info": {"S": "OperationID=abc123"}
    }
}
```

**Step 4 — Scan the table**

```bash
aws dynamodb scan \
  --table-name terraform-locks \
  --endpoint-url http://localhost:4566 2>/dev/null || \
aws dynamodb scan --table-name terraform-locks
```

**Step 5 — Delete a lock (simulate unlock)**

```bash
aws dynamodb delete-item \
  --table-name terraform-locks \
  --key '{"LockID": {"S": "prod/terraform.tfstate"}}' \
  --endpoint-url http://localhost:4566 2>/dev/null || \
aws dynamodb delete-item \
  --table-name terraform-locks \
  --key '{"LockID": {"S": "prod/terraform.tfstate"}}'

# Verify deletion
aws dynamodb scan \
  --table-name terraform-locks \
  --endpoint-url http://localhost:4566 2>/dev/null | grep Count || \
aws dynamodb scan --table-name terraform-locks | grep Count
```

Expected output:

```json
"Count": 0,
```

**Step 6 — Connect to the full S3 + DynamoDB backend pattern**

```bash
cat <<'EOF'
# Complete Terraform backend for team use:

terraform {
  backend "s3" {
    bucket         = "my-terraform-state"
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
    # LockID partition key required in DynamoDB table
  }
}
EOF
```

### Validation Checklist

- [ ] DynamoDB table `terraform-locks` created with `LockID` as the String partition key
- [ ] `put-item` successfully adds a lock record
- [ ] `get-item` retrieves the lock record by `LockID`
- [ ] `delete-item` removes the lock record; scan shows `Count: 0`
- [ ] Understands that Terraform automatically creates/deletes DynamoDB entries when locking/unlocking state
- [ ] Connects DynamoDB + S3 pattern to the Terraform S3 backend `dynamodb_table` argument

### Common Errors

| Error | Cause | Fix |
|-------|-------|-----|
| `ResourceNotFoundException` | Table doesn't exist | `create-table` first |
| `ValidationException on LockID` | Attribute name mismatch | Must be `LockID` exactly (Terraform hardcoded) |
| `Error: State Locked` in Terraform | DynamoDB lock not released | `terraform force-unlock <lock-id>` or delete item manually |

---

## Summary

| Warm-Up | Girus Lab | Key Skills Practiced | Cert Objective |
|---------|-----------|---------------------|---------------|
| WU-1 | `terraform-fundamentos` | init/plan/apply/destroy, HCL, state, console | 2, 3, 4 |
| WU-2 | `aws-s3-storage` | S3 create/versioning/delete, backend config | 6 (remote state) |
| WU-3 | `aws-localstack-terraform` | AWS provider with LocalStack, full workflow | 3, 4 |
| WU-4 | `terraform-provisioners-modulos` | local-exec, module structure, module outputs | 4 (config), 5 (modules) |
| WU-5 | `aws-dynamodb-nosql` | DynamoDB table, put/get/delete, state locking | 6 (state locking) |
