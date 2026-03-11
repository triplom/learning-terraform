# Learning Terraform

This is the repository for the LinkedIn Learning course **Learning Terraform**, extended with improvements and multi-cloud support for both **AWS** and **Azure**. The original course is available from [LinkedIn Learning][lil-course-url].

![Learning Terraform][lil-thumbnail-url]

Terraform is a DevOps tool for declarative infrastructure—infrastructure as code. It simplifies and accelerates the configuration of cloud-based environments. In this course, instructor Josh Samuelson shows how to use Terraform to configure infrastructure and manage resources with Amazon Web Services (AWS). After demonstrating how to set up AWS for Terraform, Josh covers how Terraform manages your infrastructure, as well as how to use core Terraform commands. He also delves into more advanced topics, including how to leverage code modules from the Terraform registry and how to create your own modules.

This repository has been **extended beyond the original course** to include:

- ✅ Fixed and improved AWS Terraform code (variables, outputs, versioning, security)
- ☁️ Equivalent Azure infrastructure code using the AzureRM provider
- � Local Docker environment for testing without any cloud account
- �📁 Restructured project layout with dedicated `aws/`, `azure/`, and `local/` directories

---

## Project Structure

```text
learning-terraform/
├── aws/                        # Standalone AWS Terraform module
│   ├── providers.tf            # AWS provider (hashicorp/aws ~> 5.0)
│   ├── variables.tf            # region, instance_type, environment, bucket_name
│   ├── main.tf                 # EC2 (Bitnami Tomcat) + S3 bucket
│   └── outputs.tf              # AMI ID, ARN, public IP, S3 bucket name/ARN
│
├── azure/                      # Standalone Azure Terraform module
│   ├── providers.tf            # AzureRM provider (hashicorp/azurerm ~> 4.0)
│   ├── variables.tf            # location, environment, vm_size, admin, storage name
│   ├── main.tf                 # Resource Group, VNet, Subnet, Public IP, NIC,
│   │                           # Linux VM (Ubuntu + Tomcat via cloud-init),
│   │                           # Storage Account + Container
│   └── outputs.tf              # RG name, VM name/IP/ID, storage endpoint
│
├── local/                      # Local Docker Terraform module (no cloud account needed)
│   ├── providers.tf            # Docker provider (kreuzwerker/docker ~> 3.0)
│   ├── variables.tf            # ports, image tags, MinIO credentials, bucket name
│   ├── main.tf                 # Docker network, Tomcat container,
│   │                           # MinIO container + volume, minio-init bucket setup
│   ├── outputs.tf              # Tomcat URL, MinIO API + console URLs, bucket name
│   └── docker-compose.yml      # docker compose alternative (no Terraform needed)
│
├── main.tf                     # Root AWS config (course reference, improved)
├── providers.tf                # Root AWS provider (improved)
├── variables.tf                # Root variables (improved)
├── outputs.tf                  # Root outputs (improved)
└── main2.tf                    # Archived S3 experiment (merged into main.tf)
```

### AWS ↔ Azure ↔ Local Resource Mapping

| AWS Resource | Azure Equivalent | Local (Docker) Equivalent |
| --- | --- | --- |
| `aws_instance` (Bitnami Tomcat AMI) | `azurerm_linux_virtual_machine` (Ubuntu + Tomcat) | `docker_container` (`tomcat:10-jre17`) |
| EC2 instance type (e.g. `t3.nano`) | VM size (e.g. `Standard_B1s`) | Docker resource limits (`mem_limit`) |
| VPC + Subnet | `azurerm_virtual_network` + `azurerm_subnet` | `docker_network` (bridge) |
| Elastic IP + ENI | `azurerm_public_ip` + `azurerm_network_interface` | Container port mapping |
| `aws_s3_bucket` | `azurerm_storage_account` + `azurerm_storage_container` | `docker_container` (MinIO) + `docker_volume` |
| S3 bucket versioning | Storage Account blob versioning | `mc version enable` (MinIO Client) |
| S3 public access block | `public_network_access_enabled = false` | `mc anonymous set none` (MinIO Client) |
| *(no direct match)* | `azurerm_resource_group` | *(no direct match)* |

---

## Prerequisites

| Tool | Version | Notes |
| --- | --- | --- |
| [Terraform](https://developer.hashicorp.com/terraform/install) | >= 1.3.0 | Required for all modules |
| [AWS CLI](https://aws.amazon.com/cli/) | >= 2.x | Required for `aws/` module |
| [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli) | >= 2.x | Required for `azure/` module |
| [Docker Engine](https://docs.docker.com/engine/install/) | >= 24.x | Required for `local/` module |
| [Docker Compose](https://docs.docker.com/compose/install/) | >= 2.x | Required for `local/docker-compose.yml` |

---

## Getting Started

### AWS Module

```bash
# 1. Configure AWS credentials
aws configure

# 2. Navigate to the AWS module
cd aws/

# 3. Initialise — downloads the hashicorp/aws provider
terraform init

# 4. Preview the execution plan
terraform plan

# 5. Apply (creates resources in your AWS account)
terraform apply

# 6. Destroy all resources when done
terraform destroy
```

**Override variables without editing files:**

```bash
terraform apply \
  -var="aws_region=us-west-2" \
  -var="instance_type=t3.micro" \
  -var="environment=staging" \
  -var="bucket_name=my-unique-bucket-name-123"
```

---

### Azure Module

```bash
# 1. Log in to Azure
az login

# 2. (Optional) Select a specific subscription
az account set --subscription "<subscription-id>"

# 3. Navigate to the Azure module
cd azure/

# 4. Initialise — downloads the hashicorp/azurerm provider
terraform init

# 5. Preview the execution plan
terraform plan

# 6. Apply (creates resources in your Azure subscription)
terraform apply

# 7. Destroy all resources when done
terraform destroy
```

**Override variables without editing files:**

```bash
terraform apply \
  -var="location=West Europe" \
  -var="vm_size=Standard_B2s" \
  -var="environment=staging" \
  -var="storage_account_name=myuniquestorage123"
```

> **Note:** The `storage_account_name` must be globally unique, lowercase, 3–24 alphanumeric characters.  
> **Note:** Ensure `~/.ssh/id_rsa.pub` exists or override `admin_ssh_public_key_path` with your key path.

---

### Local Module (Docker)

No cloud account required. Uses the [`kreuzwerker/docker`](https://registry.terraform.io/providers/kreuzwerker/docker/latest) Terraform provider to spin up:

- **Tomcat** container → equivalent to the EC2 / Azure VM
- **MinIO** container → S3-compatible local storage, equivalent to S3 / Azure Storage Account
- **minio-init** one-shot container → creates and configures the bucket (versioning + private access)

#### Option A — via Terraform

```bash
# 1. Make sure Docker is running
docker info

# 2. Navigate to the local module
cd local/

# 3. Initialise — downloads the kreuzwerker/docker provider
terraform init

# 4. Preview the plan
terraform plan

# 5. Apply — pulls images and starts containers
terraform apply

# 6. Check outputs (URLs, bucket name, network)
terraform output

# 7. Destroy all containers, volumes and network when done
terraform destroy
```

**Override variables without editing files:**

```bash
terraform apply \
  -var="tomcat_port=8888" \
  -var="minio_port=9090" \
  -var="minio_root_password=supersecret" \
  -var="minio_bucket_name=my-test-bucket"
```

#### Option B — via Docker Compose (no Terraform needed)

```bash
# Navigate to the local module
cd local/

# Start all services in detached mode
docker compose up -d

# Tail logs for a specific service
docker compose logs -f minio

# Stop everything and remove containers (keep volumes)
docker compose down

# Stop and also remove volumes (full clean-up)
docker compose down -v
```

#### Endpoints after startup

| Service | URL | Credentials |
| --- | --- | --- |
| Tomcat web server | <http://localhost:8888> | *(none)* |
| MinIO S3 API | <http://localhost:9000> | `minioadmin` / `minioadmin` |
| MinIO web console | <http://localhost:9001> | `minioadmin` / `minioadmin` |

#### Connect an S3-compatible client to MinIO

```bash
# AWS CLI pointed at local MinIO
aws s3 ls s3://app-bucket \
  --endpoint-url http://localhost:9000 \
  --no-sign-request

# Or with explicit credentials
AWS_ACCESS_KEY_ID=minioadmin \
AWS_SECRET_ACCESS_KEY=minioadmin \
aws s3 ls s3://app-bucket \
  --endpoint-url http://localhost:9000
```

---

## Terraform Essential Commands

| Command | Description |
| --- | --- |
| `terraform init` | Initialise the working directory; downloads providers and modules |
| `terraform fmt` | Auto-format all `.tf` files to canonical HCL style |
| `terraform validate` | Validate the configuration for syntax and internal consistency |
| `terraform plan` | Show what actions Terraform will take (dry run, no changes made) |
| `terraform plan -out=tfplan` | Save the plan to a file for later use |
| `terraform apply` | Apply the changes and create/update/destroy resources |
| `terraform apply tfplan` | Apply a previously saved plan file |
| `terraform apply -auto-approve` | Apply without interactive confirmation (use with care) |
| `terraform destroy` | Destroy all resources managed by this configuration |
| `terraform output` | Display all output values after a successful apply |
| `terraform output <name>` | Display a specific output value |
| `terraform show` | Display the current state or a saved plan |
| `terraform state list` | List all resources tracked in the state file |
| `terraform state show <resource>` | Show details of a specific resource in state |
| `terraform refresh` | Sync state file with real infrastructure (deprecated; use `plan -refresh-only`) |
| `terraform import <resource> <id>` | Import an existing resource into Terraform state |
| `terraform workspace list` | List available workspaces |
| `terraform workspace new <name>` | Create a new workspace (e.g. for dev/staging/prod) |
| `terraform workspace select <name>` | Switch to a different workspace |
| `terraform graph` | Output a dependency graph in DOT format |

### Useful Flags

```bash
# Target a specific resource only
terraform plan -target=aws_instance.web
terraform apply -target=aws_s3_bucket.app_bucket

# Pass a variable file
terraform plan -var-file="prod.tfvars"

# Enable detailed logging
TF_LOG=DEBUG terraform apply

# Compact plan output
terraform plan -compact-warnings
```

---

## Course Branches

The branches are structured to correspond to the videos in the course. The naming convention is `CHAPTER#_MOVIE#`. As an example, the branch named `02_03` corresponds to the second chapter and the third video in that chapter. The code is built sequentially so each branch contains the completed code for that particular video and the starting code can be found in the previous video's branch.

The `main` branch contains the starting code for the course and the `final` branch contains the completed code.

---

### Original Course Instructor

**Josh Samuelson** — DevOps Engineer

Check out his other courses on [LinkedIn Learning](https://www.linkedin.com/learning/instructors/josh-samuelson).

[lil-course-url]: https://www.linkedin.com/learning/learning-terraform-15575129?dApp=59033956
[lil-thumbnail-url]: https://cdn.lynda.com/course/3087701/3087701-1666200696363-16x9.jpg
