terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Data source para obter a região atual dinamicamente (usado no output da Hosted UI)
data "aws_region" "current" {}

# ----- Cognito User Pool -----
resource "aws_cognito_user_pool" "main" {
  name = "${var.user_pool_base_name}-${var.environment}"

  # Atributos de login e verificação
  username_attributes      = ["email"]
  auto_verified_attributes = ["email"]

  # Schema: Apenas o atributo 'email' é definido e requerido pelo Cognito
  schema {
    attribute_data_type = "String"
    name                = "email"
    required            = true
    mutable             = false
  }

  # Política de Senha
  password_policy {
    minimum_length                   = 8
    require_lowercase                = true
    require_numbers                  = true
    require_symbols                  = true
    require_uppercase                = true
    temporary_password_validity_days = 7
  }

  mfa_configuration = "OFF"

  # Configuração de Recuperação de Conta (via email verificado)
  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }
  }

  # Tags do projeto e ambiente
  tags = merge(
    var.project_tags,
    {
      Environment = var.environment
      Name        = "${var.user_pool_base_name}-${var.environment}"
    }
  )
}

# ----- Domínio para Hosted UI -----
resource "aws_cognito_user_pool_domain" "main" {
  # Usa variáveis para construir o prefixo do domínio
  domain       = "${var.user_pool_domain_prefix}-${var.environment}"
  user_pool_id = aws_cognito_user_pool.main.id
}

# ----- App Client -----
resource "aws_cognito_user_pool_client" "app_client" {
  # Usa variáveis para construir o nome
  name = "${var.app_client_name}-${var.environment}"

  user_pool_id    = aws_cognito_user_pool.main.id
  generate_secret = false

  # Habilita o próprio User Pool como provedor de identidade
  supported_identity_providers = ["COGNITO"]

  allowed_oauth_flows                  = var.app_client_oauth_flows
  allowed_oauth_scopes                 = var.app_client_oauth_scopes
  callback_urls                        = var.app_client_callback_urls
  logout_urls                          = var.app_client_logout_urls
  allowed_oauth_flows_user_pool_client = true # Habilita o uso dos fluxos OAuth

  # Fluxos de autenticação explícitos permitidos (SRP é mais seguro)
  explicit_auth_flows = ["ALLOW_USER_SRP_AUTH", "ALLOW_REFRESH_TOKEN_AUTH"]

  # Medida de segurança para não revelar se usuário existe em fluxos não autenticados
  prevent_user_existence_errors = "ENABLED"

  access_token_validity = 120
  id_token_validity     = 120

  token_validity_units {
    access_token = "minutes"
    id_token     = "minutes"
  }
}