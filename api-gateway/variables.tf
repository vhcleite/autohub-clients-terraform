variable "aws_region" {
  description = "Região AWS onde os recursos serão criados"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Ambiente de deploy (ex: dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "api_gateway_name_prefix" {
  description = "Prefixo para o nome da API Gateway HTTP API compartilhada"
  type        = string
  default     = "AutoHubSharedHttpApi"
}

variable "project_tags" {
  description = "Tags comuns para aplicar aos recursos"
  type        = map(string)
  default = {
    Project   = "AutoHub"
    Service   = "SharedAPI"
    ManagedBy = "Terraform"
  }
}