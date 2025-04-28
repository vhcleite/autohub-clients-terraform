# terraform/lambda-vehicles/data.tf

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

# Lê o estado do API Gateway compartilhado
data "terraform_remote_state" "api_gateway" {
  backend = "s3"
  config = {
    bucket = var.terraform_state_bucket
    key    = "api-gateway/${var.environment}/terraform.tfstate"
    region = var.aws_region
  }
}

# Lê o estado do RDS de Veículos dedicado
data "terraform_remote_state" "rds_vehicles" {
  backend = "s3"
  config = {
    bucket = var.terraform_state_bucket
    key    = "rds-vehicles/${var.environment}/terraform.tfstate" # Chave do estado RDS Veículos
    region = var.aws_region
  }
}

# Lê o estado do Cognito (para o Issuer URI)
data "terraform_remote_state" "cognito" {
  backend = "s3"
  config = {
    bucket = var.terraform_state_bucket
    key    = "cognito/${var.environment}/terraform.tfstate"
    region = var.aws_region
  }
}

# Lê o estado do S3 Artifacts (para pegar nome do bucket de deploy)
data "terraform_remote_state" "s3_artifacts" {
  backend = "s3"
  config = {
    bucket = var.terraform_state_bucket
    key    = "s3-artifacts/${var.environment}/terraform.tfstate"
    region = var.aws_region
  }
}

# Lê o estado de Mensageria se precisar de ARNs/URLs de SQS/SNS
data "terraform_remote_state" "messaging" {
  backend = "s3"
  config = {
    bucket = var.terraform_state_bucket
    key    = "messaging/${var.environment}/terraform.tfstate"
    region = var.aws_region
  }
}