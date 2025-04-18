# terraform/database-clients/variables.tf

variable "aws_region" {
  description = "Região AWS onde a tabela DynamoDB será criada"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Ambiente de deploy (ex: dev, staging, prod) usado para nomear recursos"
  type        = string
  default     = "dev"
}

variable "dynamodb_table_name" {
  description = "Nome base para a tabela DynamoDB de usuários/clientes"
  type        = string
  default     = "AutoHubUsers"
}

variable "project_tags" {
  description = "Tags comuns para aplicar a todos os recursos"
  type        = map(string)
  default = {
    Project   = "AutoHub"
    Service   = "ClientsDB"
    ManagedBy = "Terraform"
  }
}