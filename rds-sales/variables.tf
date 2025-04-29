# terraform/rds-sales/variables.tf

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
    Service   = "SalesDB"
    ManagedBy = "Terraform"
  }
}

variable "sales_db_identifier" {
  description = "Identificador da instância RDS para Vendas"
  type        = string
  default     = "autohub-sales-db"
}

variable "sales_db_name" {
  description = "Nome do banco de dados inicial a ser criado na instância RDS"
  type        = string
  default     = "autohub_sales"
}

variable "sales_db_instance_class" {
  description = "Classe da instância RDS. Escolha pequena para custo baixo."
  type        = string
  default     = "db.t3.micro" # Classe Burstable pequena e barata (verificar disponibilidade na região)
  # Alternativa ARM (pode ser mais barata): "db.t4g.micro"
}

variable "sales_db_allocated_storage" {
  description = "Armazenamento inicial em GB"
  type        = number
  default     = 20 # Mínimo para muitas regiões/tipos, suficiente para começar
}

variable "sales_db_engine_version" {
  description = "Versão do PostgreSQL"
  type        = string
  default     = "15" # Use uma versão LTS suportada pelo RDS (ex: 15, 16)
}

variable "sales_db_username" {
  description = "Nome do usuário master do banco de dados"
  type        = string
  default     = "salesadmin"
}

variable "vpc_private_subnet_ids" {
  description = "Lista de IDs das subnets PRIVADAS onde o RDS será criado (precisa de pelo menos 2 AZs diferentes para subnet group)"
  type        = list(string)
  # Não há default aqui, você PRECISA passar isso via .tfvars ou -var
  # Ex: -var='vpc_private_subnet_ids=["subnet-abc", "subnet-def"]'
}

variable "lambda_security_group_id" {
  description = "ID do Security Group associado à Lambda da Sales API (para permitir acesso ao DB)"
  type        = string
  # Não há default, será lido do remote state do lambda-sales ou passado como var
  # Este não é usado diretamente aqui, mas o SG do DB usará para regra de entrada
}

variable "vpc_id" {
  description = "ID da VPC onde os recursos serão criados"
  type        = string
  # Não há default, precisa ser fornecido ou lido de outro state/data source
}