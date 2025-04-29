# terraform/rds-sales/main.tf
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = { # Provider para gerar senha
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# --- Segurança ---

# Security Group para a instância RDS
resource "aws_security_group" "sales_db_sg" {
  name        = "${var.sales_db_identifier}-${var.environment}-sg"
  description = "Allow access to Sales DB from Sales Lambda"
  vpc_id      = var.vpc_id

  # Regra de Entrada: Permite tráfego na porta Postgres (5432)
  # SOMENTE a partir do Security Group da Lambda de Vendas
  ingress {
    description     = "Allow Postgres connection from Sales Lambda"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [var.lambda_security_group_id]
  }

  # Regra de Saída: Permite todo tráfego de saída (padrão, pode restringir se necessário)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.project_tags, { Name = "${var.sales_db_identifier}-${var.environment}-sg" })
}


# --- Rede ---

# Grupo de Sub-rede para o RDS (instrui em quais subnets ele pode ser criado)
resource "aws_db_subnet_group" "sales_db_subnet_group" {
  name       = "${var.sales_db_identifier}-${var.environment}-sng"
  subnet_ids = var.vpc_private_subnet_ids
  tags       = merge(var.project_tags, { Name = "${var.sales_db_identifier}-${var.environment}-sng" })
}

# --- Senha Segura ---

# Gera uma senha aleatória segura
resource "random_password" "db_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?" # Caracteres especiais permitidos pelo RDS
}

# Armazena a senha gerada no AWS Secrets Manager
resource "aws_secretsmanager_secret" "db_password_secret" {
  name        = "${var.sales_db_identifier}-${var.environment}-password"
  description = "Password for the Sales DB master user"
  # Força a sobrescrita do segredo se a senha mudar no Terraform (útil se rodar apply de novo)
  force_overwrite_replica_secret = true

  tags = merge(var.project_tags, { Name = "${var.sales_db_identifier}-${var.environment}-password" })
}

# Define a versão atual do secret com a senha gerada
resource "aws_secretsmanager_secret_version" "db_password_version" {
  secret_id     = aws_secretsmanager_secret.db_password_secret.id
  secret_string = random_password.db_password.result
}


# --- Instância RDS Postgres ---

resource "aws_db_instance" "sales_db" {
  # Identificador único da instância na AWS
  identifier = "${var.sales_db_identifier}-${var.environment}"

  # Configurações do Banco
  engine            = "postgres"
  engine_version    = var.sales_db_engine_version
  instance_class    = var.sales_db_instance_class    # Classe pequena/barata
  allocated_storage = var.sales_db_allocated_storage # Armazenamento pequeno inicial
  storage_type      = "gp3"                          # SSD de uso geral (bom custo/benefício)
  # iops                      = 1000                           # Necessário apenas para storage 'io1'/'io2'
  db_name                       = var.sales_db_name                                       # Nome do banco inicial
  username                      = var.sales_db_username                                   # Usuário master
  
  password = random_password.db_password.result # Passa a senha gerada
  
  # Rede
  db_subnet_group_name   = aws_db_subnet_group.sales_db_subnet_group.name # Grupo de sub-rede criado acima
  vpc_security_group_ids = [aws_security_group.sales_db_sg.id]            # Security Group criado acima
  publicly_accessible    = false                                          # IMPORTANTE: Não deixar o banco acessível publicamente

  # --- Configurações de Custo/Desenvolvimento ---
  multi_az                = false # DESABILITADO para custo baixo (SEM alta disponibilidade)
  skip_final_snapshot     = true  # Pula o snapshot final ao destruir (MAIS RÁPIDO/BARATO para dev, NÃO FAÇA EM PROD)
  backup_retention_period = 0     # DESABILITA backups automáticos (MAIS BARATO, MUITO RISCADO, apenas para dev/teste onde dados são descartáveis)
  # deletion_protection    = false # Padrão é false, manter assim para dev

  # Manutenção e Outros
  apply_immediately = true # Aplica mudanças imediatamente (OK para dev)
  # parameter_group_name = aws_db_parameter_group.default_postgres.name # Usar grupo de parâmetros default ou customizado
  # option_group_name    = aws_db_option_group.default_postgres.name # Usar grupo de opções default ou customizado

  tags = merge(
    var.project_tags,
    {
      Name        = "${var.sales_db_identifier}-${var.environment}"
      Environment = var.environment
    }
  )

  # Garante que o segredo exista antes de tentar criar a instância referenciando-o
  depends_on = [aws_secretsmanager_secret_version.db_password_version]
}