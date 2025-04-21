terraform {
  required_providers {
    aws    = { source = "hashicorp/aws", version = "~> 5.0" }
    random = { source = "hashicorp/random", version = "~> 3.5" }
  }
}

provider "aws" {
  region = var.aws_region
}

data "aws_caller_identity" "current" {}

# --- Segurança ---
resource "aws_security_group" "vehicles_db_sg" {
  name        = "${var.vehicles_db_instance_identifier}-${var.environment}-sg"
  description = "Allow access to Vehicles DB from Vehicles Lambda"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow Postgres connection from Vehicles Lambda SG"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    # Fonte é o SG da Lambda de VEÍCULOS (passado como variável)
    security_groups = [var.lambda_vehicles_security_group_id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = merge(var.project_tags, { Name = "${var.vehicles_db_instance_identifier}-${var.environment}-sg" })
}

# --- Rede ---
resource "aws_db_subnet_group" "vehicles_db_subnet_group" {
  name       = "${var.vehicles_db_instance_identifier}-${var.environment}-sng"
  subnet_ids = var.vpc_private_subnet_ids
  tags       = merge(var.project_tags, { Name = "${var.vehicles_db_instance_identifier}-${var.environment}-sng" })
}

# --- Senha Segura ---
resource "random_password" "db_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}
resource "aws_secretsmanager_secret" "db_password_secret" {
  name                           = "${var.vehicles_db_instance_identifier}-${var.environment}-password"
  description                    = "Password for the Vehicles DB master user"
  force_overwrite_replica_secret = true
  tags                           = merge(var.project_tags, { Name = "${var.vehicles_db_instance_identifier}-${var.environment}-password" })
}
resource "aws_secretsmanager_secret_version" "db_password_version" {
  secret_id     = aws_secretsmanager_secret.db_password_secret.id
  secret_string = random_password.db_password.result
}

# --- Instância RDS Postgres ---
resource "aws_db_instance" "vehicles_db" {
  identifier = "${var.vehicles_db_instance_identifier}-${var.environment}"

  engine            = "postgres"
  engine_version    = var.vehicles_db_engine_version
  instance_class    = var.vehicles_db_instance_class    # Classe barata
  allocated_storage = var.vehicles_db_allocated_storage # Armazenamento pequeno
  storage_type      = "gp3"
  db_name           = var.vehicles_db_name
  username          = var.vehicles_db_username
  password          = random_password.db_password.result # Define a senha diretamente

  db_subnet_group_name   = aws_db_subnet_group.vehicles_db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.vehicles_db_sg.id]
  publicly_accessible    = false

  # --- Configurações de Custo/Desenvolvimento ---
  multi_az                = false # Sem alta disponibilidade
  skip_final_snapshot     = true  # Sem snapshot ao destruir
  backup_retention_period = 0     # SEM BACKUPS AUTOMÁTICOS! (CUIDADO!)
  # deletion_protection     = false

  apply_immediately = true
  tags = merge(
    var.project_tags,
    {
      Name        = "${var.vehicles_db_instance_identifier}-${var.environment}"
      Environment = var.environment
    }
  )
  depends_on = [aws_secretsmanager_secret_version.db_password_version]
}