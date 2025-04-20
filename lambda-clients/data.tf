data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

data "terraform_remote_state" "api_gateway" {
  backend = "s3"
  config = {
    bucket = var.terraform_state_bucket # Passar via -var ou tfvars
    key    = "api-gateway/${var.environment}/terraform.tfstate"
    region = var.aws_region
  }
}

# Lê o estado do Banco de Dados de Clientes (DynamoDB)
data "terraform_remote_state" "database_clients" {
  backend = "s3"
  config = {
    bucket = var.terraform_state_bucket
    key    = "database-clients/${var.environment}/terraform.tfstate"
    region = var.aws_region
  }
}

# Lê o estado do Cognito
data "terraform_remote_state" "cognito" {
  backend = "s3"
  config = {
    bucket = var.terraform_state_bucket
    key    = "cognito/${var.environment}/terraform.tfstate"
    region = var.aws_region
  }
}


data "terraform_remote_state" "s3_artifacts" {
  backend = "s3"
  config = {
    bucket = var.terraform_state_bucket
    key    = "s3-artifacts/${var.environment}/terraform.tfstate"
    region = var.aws_region
  }
}