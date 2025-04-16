# Busca informações sobre a região e conta AWS sendo usadas
data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

# Busca outputs do estado remoto do módulo 'database'
data "terraform_remote_state" "database" {
  backend = "s3"
  config = {
    bucket = "vhc-terraform-state-autohub-clients-v1"
    key    = "user-dynamodb/dev/terraform.tfstate"
    region = var.aws_region
  }
}

# Busca outputs do estado remoto do módulo 'cognito' (se precisar de algo dele)
data "terraform_remote_state" "cognito" {
  backend = "s3"
  config = {
    bucket = "vhc-terraform-state-autohub-clients-v1"
    key    = "cognito/dev/terraform.tfstate"
    region = var.aws_region
  }
}
