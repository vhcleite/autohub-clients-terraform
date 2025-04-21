variable "aws_region" {
  description = "Região AWS"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Ambiente (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "project_tags" {
  description = "Tags comuns"
  type        = map(string)
  default = {
    Project   = "AutoHub"
    Service   = "VehiclesDB"
    ManagedBy = "Terraform"
  }
}

variable "vehicles_db_instance_identifier" {
  description = "Identificador da instância RDS para Veículos"
  type        = string
  default     = "autohub-vehicles-db" # Nome base diferente do de vendas
}

variable "vehicles_db_name" {
  description = "Nome do banco de dados inicial a ser criado na instância RDS"
  type        = string
  default     = "autohub_vehicles" # Nome do DB diferente
}

variable "vehicles_db_instance_class" {
  description = "Classe da instância RDS. Mantenha pequena/barata para dev."
  type        = string
  default     = "db.t3.micro" # Mantendo a instância pequena
}

variable "vehicles_db_allocated_storage" {
  description = "Armazenamento inicial em GB"
  type        = number
  default     = 20 # Mantendo pequeno
}

variable "vehicles_db_engine_version" {
  description = "Versão do PostgreSQL"
  type        = string
  default     = "15"
}

variable "vehicles_db_username" {
  description = "Nome do usuário master do banco de dados"
  type        = string
  default     = "vehiclesadmin"
}

# --- Variáveis OBRIGATÓRIAS (sem default) ---

variable "vpc_id" {
  description = "ID da VPC onde o RDS será criado (deve ser a mesma VPC dos outros recursos)"
  type        = string
  # Será passado via -var ou tfvars
}

variable "vpc_private_subnet_ids" {
  description = "Lista de IDs das subnets PRIVADAS onde o RDS será criado (mesmas usadas pelo rds-sales)"
  type        = list(string)
  # Será passado via -var ou tfvars (ex: -var='vpc_private_subnet_ids=["subnet-abc", "subnet-def"]')
}

variable "lambda_vehicles_security_group_id" {
  description = "ID do Security Group que SERÁ associado à Lambda da Vehicles API (para permitir acesso ao DB)"
  type        = string
  # Será passado via -var ou tfvars (você precisará criar/identificar este SG depois no módulo lambda-vehicles)
}