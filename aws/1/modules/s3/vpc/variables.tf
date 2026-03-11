terraform variable "vpc_name" { description = "Nome da VPC" type        = string }
variable "vpc_cidr" { description = "CIDR block para a VPC" type        = string default     = "10.0.0.0/16" }
variable "azs" { description = "Zonas de disponibilidade" type        = list(string) default     = ["us-east-1a", "us-east-1b"] }
variable "public_subnets" { description = "Lista de CIDRs para subnets públicas" type        = list(string) default     = [] }
variable "private_subnets" { description = "Lista de CIDRs para subnets privadas" type        = list(string) default     = [] }
variable "tags" { description = "Tags a serem aplicadas aos recursos" type        = map(string) default     = {} }