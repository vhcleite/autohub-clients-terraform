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
  description = "Allow access to Sales DB"
  vpc_id      = var.vpc_id 

  ingress {
    description = "Allow Postgres connection from anywhere (Lambda outside VPC - REVIEW SECURITY)"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }

  # Regra de Saída: Permite todo tráfego de saída (padrão)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.project_tags, { Name = "${var.sales_db_identifier}-${var.environment}-sg" })
}


# --- Rede ---

resource "aws_db_subnet_group" "sales_db_subnet_group" {
  name       = "${var.sales_db_identifier}-${var.environment}-sng"
  subnet_ids = var.vpc_subnet_ids 
  tags       = merge(var.project_tags, { Name = "${var.sales_db_identifier}-${var.environment}-sng" })
}

# --- Senha Segura ---

# Gera uma senha aleatória segura
resource "random_password" "db_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# Armazena a senha gerada no AWS Secrets Manager
resource "aws_secretsmanager_secret" "db_password_secret" {
  name        = "${var.sales_db_identifier}-${var.environment}-password"
  description = "Password for the Sales DB master user"
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
  identifier = "${var.sales_db_identifier}-${var.environment}"

  # Configurações do Banco
  engine            = "postgres"
  engine_version    = var.sales_db_engine_version
  instance_class    = var.sales_db_instance_class
  allocated_storage = var.sales_db_allocated_storage
  storage_type      = "gp3"
  db_name           = var.sales_db_name
  username          = var.sales_db_username
  password          = random_password.db_password.result

  # Rede
  db_subnet_group_name   = aws_db_subnet_group.sales_db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.sales_db_sg.id]
  publicly_accessible    = true

  
  multi_az                = false
  skip_final_snapshot     = true
  backup_retention_period = 0
  # deletion_protection    = false

  apply_immediately = true

  tags = merge(
    var.project_tags,
    {
      Name        = "${var.sales_db_identifier}-${var.environment}"
      Environment = var.environment
    }
  )

  depends_on = [aws_secretsmanager_secret_version.db_password_version]
}
