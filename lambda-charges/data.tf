data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

data "terraform_remote_state" "api_gateway" {
  backend = "s3"
  config = {
    bucket = var.terraform_state_bucket
    key    = "api-gateway/${var.environment}/terraform.tfstate"
    region = var.aws_region
  }
}

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

# Lê o estado de Mensageria para obter ARNs de SQS/SNS
data "terraform_remote_state" "messaging" {
  backend = "s3"
  config = {
    bucket = var.terraform_state_bucket
    key    = "messaging/${var.environment}/terraform.tfstate"
    region = var.aws_region
  }
}

# Lê o estado do DynamoDB da Charges API
data "terraform_remote_state" "dynamodb_charges" {
  backend = "s3"
  config = {
    bucket = var.terraform_state_bucket
    key    = "dynamodb-charges/${var.environment}/terraform.tfstate"
    region = var.aws_region
  }
}
