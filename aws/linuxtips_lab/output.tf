terraform output "vpc_id" { description = "ID da VPC criada" value       = module.vpc.vpc_id }
output "vpc_cidr" { description = "CIDR da VPC" value       = module.vpc.vpc_cidr }
output "public_subnet_ids" { description = "IDs das subnets públicas" value       = module.vpc.public_subnet_ids }
output "logs_bucket_name" { description = "Nome do bucket de logs" value       = module.logs_bucket.bucket_id }
output "data_bucket_name" { description = "Nome do bucket de dados" value       = module.data_bucket.bucket_id } 