variable "aws_region" {
  description = "Região AWS"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Ambiente de deploy"
  type        = string
  default     = "dev"
}

variable "lambda_deploy_bucket_name_prefix" {
  description = "Prefixo para o nome do bucket S3 de deploy Lambda"
  type        = string
  default     = "autohub-lambda-deploy"
}

variable "project_tags" {
  description = "Tags comuns para aplicar aos recursos"
  type        = map(string)
  default = {
    Project   = "AutoHub"
    Service   = "s3-deploy"
    ManagedBy = "Terraform"
  }
}