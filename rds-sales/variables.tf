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

variable "vpc_subnet_ids" {
  description = "Lista de IDs das subnets onde o RDS será criado (públicas ou privadas, dependendo da estratégia de acesso)"
  type        = list(string)
}

variable "vpc_id" {
  description = "ID da VPC onde os recursos de rede (SG, Subnet Group) serão criados"
  type        = string
}
