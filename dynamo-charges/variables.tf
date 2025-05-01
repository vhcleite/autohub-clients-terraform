variable "aws_region" {
  description = "Região AWS onde a tabela DynamoDB será criada"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Ambiente de deploy (ex: dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "project_tags" {
  description = "Tags comuns para aplicar aos recursos"
  type        = map(string)
  default = {
    Project   = "AutoHub"
    Service   = "ChargesDB"
    ManagedBy = "Terraform"
  }
}

variable "charges_table_name" {
  description = "Nome base para a tabela DynamoDB de Cobranças"
  type        = string
  default     = "AutoHubCharges"
}

variable "gsi_sale_id_name" {
  description = "Nome do Índice Secundário Global para buscar por sale_id"
  type        = string
  default     = "saleId-index"
}
