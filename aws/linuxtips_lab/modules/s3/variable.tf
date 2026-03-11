terraform variable "bucket_name" { description = "Nome do bucket S3" type        = string }
variable "versioning_enabled" { description = "Habilitar ou não o versionamento de objetos" type        = bool default     = false }
variable "tags" { description = "Tags a serem aplicadas ao bucket" type        = map(string) default     = {} } 