terraform {
  required_providers { aws = { source = "hashicorp/aws", version = "~> 5.0" } }
}

provider "aws" {
  region = var.aws_region
}

data "aws_caller_identity" "current" {}

# --- Bucket S3 para Artefatos Lambda ---
resource "aws_s3_bucket" "lambda_deployments" {
  bucket        = lower("${var.lambda_deploy_bucket_name_prefix}-${data.aws_caller_identity.current.account_id}-${var.aws_region}-${var.environment}")
  force_destroy = true
  tags = merge(
    var.project_tags,
    {
      Name        = "${var.lambda_deploy_bucket_name_prefix}-${var.environment}"
      Environment = var.environment
    }
  )
}

# Habilita versionamento (bom para histórico e rollback de artefatos)
resource "aws_s3_bucket_versioning" "lambda_deployments_versioning" {
  bucket = aws_s3_bucket.lambda_deployments.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Bloqueia acesso público (boa prática de segurança)
resource "aws_s3_bucket_public_access_block" "lambda_deployments_public_access" {
  bucket                  = aws_s3_bucket.lambda_deployments.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Opcional: Limpa versões antigas de objetos após X dias
resource "aws_s3_bucket_lifecycle_configuration" "lambda_deployments_lifecycle" {
  bucket = aws_s3_bucket.lambda_deployments.id
  rule {
    id     = "ExpireOldVersions"
    status = "Enabled"
    filter {
      prefix = ""
    }
    noncurrent_version_expiration {
      noncurrent_days = 30 # Ex: Guarda versões não correntes por 30 dias
    }
    abort_incomplete_multipart_upload {
      days_after_initiation = 7 # Limpa uploads incompletos
    }
  }
}