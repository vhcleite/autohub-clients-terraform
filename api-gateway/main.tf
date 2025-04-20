terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  # Backend configurado em backend.tf
}

provider "aws" {
  region = var.aws_region
}

# --- API Gateway HTTP API (Recurso Compartilhado) ---
resource "aws_apigatewayv2_api" "shared_http_api" {
  name          = "${var.api_gateway_name_prefix}-${var.environment}"
  protocol_type = "HTTP" # API HTTP, mais simples e performática para Lambda Proxy
  description   = "Shared API Gateway for AutoHub Services"

  # Configuração de CORS básica - permite chamadas de qualquer origem (AJUSTE PARA PRODUÇÃO!)
  cors_configuration {
    allow_origins = ["*"] # Em produção, liste aqui as URLs do seu frontend
    allow_methods = ["GET", "POST", "PUT", "DELETE", "PATCH", "OPTIONS"]
    # Headers comuns necessários, incluindo Authorization para JWT
    allow_headers = ["Content-Type", "Authorization", "X-Amz-Date", "X-Api-Key", "X-Amz-Security-Token"]
    max_age       = 300 # Tempo de cache para preflight OPTIONS
  }

  tags = merge(
    var.project_tags,
    {
      Name        = "${var.api_gateway_name_prefix}-${var.environment}"
      Environment = var.environment
    }
  )
}

# --- Stage Padrão de Deploy ---
# Cria o stage '$default' que torna a API invocável na URL raiz gerada.
resource "aws_apigatewayv2_stage" "default_stage" {
  api_id      = aws_apigatewayv2_api.shared_http_api.id # Associa ao API Gateway criado acima
  name        = "$default"                              # Nome especial para o stage padrão
  auto_deploy = true                                    # Faz deploy automático a cada mudança na API (bom para dev)

  # Opcional: Configurar logs de acesso para o API Gateway
  # access_log_settings { ... }

  tags = merge(
    var.project_tags,
    {
      Name        = "${var.api_gateway_name_prefix}-${var.environment}-stage"
      Environment = var.environment
    }
  )
}