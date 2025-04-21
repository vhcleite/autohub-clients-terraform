variable "aws_region" {
  description = "Região AWS"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Ambiente de deploy"
  type        = string
  default     = "dev"
}

variable "project_tags" {
  description = "Tags comuns"
  type        = map(string)
  default = {
    Project   = "AutoHub"
    Service   = "VehiclesApi"
    ManagedBy = "Terraform"
  }
}

variable "lambda_function_name" {
  description = "Nome base para a função Lambda da API de Veículos"
  type        = string
  default     = "AutoHubVehiclesApi"
}

variable "lambda_jar_path" {
  description = "OBRIGATÓRIO: Caminho para o JAR da API de Veículos"
  type        = string
  # Sem default, passar via -var
}

# Variáveis relacionadas à rede (assumindo que você tem os IDs)
variable "vpc_id" {
  description = "ID da VPC onde a Lambda e o SG serão criados"
  type        = string
  # Sem default, passar via -var ou ler de remote state 'network'
}

# Variáveis para conexão com estados remotos
variable "terraform_state_bucket" {
  description = "Bucket com o tf state"
  type        = string
  default     = "vhc-terraform-state-autohub-clients-v1"
}

# Variáveis de configuração da Lambda
variable "lambda_memory_size" {
  description = "Memória para a Lambda de Veículos (MB)"
  type        = number
  default     = 1024
}
variable "lambda_timeout" {
  description = "Timeout da Lambda de Veículos (segundos)"
  type        = number
  default     = 60
}
variable "lambda_runtime" {
  description = "Runtime Java"
  type        = string
  default     = "java21"
}
variable "lambda_handler" {
  description = "Handler da função Lambda (usando aws-serverless-java-container)"
  type        = string
  default     = "com.fiap.autohub.autohub_vehicles_api.application.config.StreamLambdaHandler"
}