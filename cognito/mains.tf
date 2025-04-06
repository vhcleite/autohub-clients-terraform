# Bloco de configuração do Terraform
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Bloco de configuração do provedor AWS
provider "aws" {
  region = "us-east-1" # Ou sua região
}

# Data source para obter informações sobre a região AWS atual configurada
data "aws_region" "current" {}

# Recurso aws_cognito_user_pool
resource "aws_cognito_user_pool" "main" {
  name                     = "vehicle-resale-user-pool"
  username_attributes      = ["email"]
  auto_verified_attributes = ["email"]

  # Schema para atributos padrão
  schema {
    attribute_data_type = "String"
    name                = "email"
    required            = true
    mutable             = false
  }
  schema {
    attribute_data_type = "String"
    name                = "given_name"
    required            = true
    mutable             = true
  }
  schema {
    attribute_data_type = "String"
    name                = "family_name"
    required            = true
    mutable             = true
  }

  password_policy {
    minimum_length                   = 8
    require_lowercase                = true
    require_numbers                  = true
    require_symbols                  = true
    require_uppercase                = true
    temporary_password_validity_days = 7
  }
  mfa_configuration = "OFF"
  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }
  }
  tags = {
    Environment = "development"
    Project     = "VehicleResale"
    ManagedBy   = "Terraform"
  }
}

# Recurso que define o domínio para o User Pool (necessário para a Hosted UI)
resource "aws_cognito_user_pool_domain" "main" {
  domain = "fiap-vehicle-resale"
  # ID do User Pool ao qual este domínio pertence
  user_pool_id = aws_cognito_user_pool.main.id
}

# Recurso que define um Cliente de Aplicativo para o User Pool
resource "aws_cognito_user_pool_client" "app_client" {
  name            = "vehicle-resale-app-client"
  user_pool_id    = aws_cognito_user_pool.main.id
  generate_secret = false
  supported_identity_providers = ["COGNITO"]

  # Habilita AMBOS os fluxos: Authorization Code e Implicit
  allowed_oauth_flows = ["code", "implicit"]

  # Fluxos de autenticação explícitos
  explicit_auth_flows           = ["ALLOW_USER_SRP_AUTH", "ALLOW_REFRESH_TOKEN_AUTH"]
  prevent_user_existence_errors = "ENABLED"

  # Escopos OAuth
  allowed_oauth_scopes = ["openid", "email", "profile"]

  # URLs de Callback
  callback_urls = ["https://jwt.io"]

  # URLs de Logout
  logout_urls = ["https://jwt.io/logout"]

  # Habilita os fluxos OAuth
  allowed_oauth_flows_user_pool_client = true
}

# Bloco de Saída
output "cognito_user_pool_id" {
  description = "O ID do Cognito User Pool criado"
  value       = aws_cognito_user_pool.main.id
}
output "cognito_user_pool_client_id" {
  description = "O ID do Cognito User Pool Client criado"
  value       = aws_cognito_user_pool_client.app_client.id
}
output "cognito_hosted_ui_domain" {
  description = "O domínio completo configurado para a Hosted UI do Cognito"
  value       = "https://${aws_cognito_user_pool_domain.main.domain}.auth.${data.aws_region.current.name}.amazoncognito.com"
}