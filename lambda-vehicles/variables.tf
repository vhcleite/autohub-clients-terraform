# terraform/lambda-vehicles/variables.tf

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

variable "lambda_function_name_http" {
  description = "Nome base para a função Lambda da API HTTP de Veículos"
  type        = string
  default     = "AutoHubVehiclesApiHttp" # Novo nome base
}

variable "lambda_function_name_sqs" {
  description = "Nome base para a função Lambda do Listener SQS de Veículos"
  type        = string
  default     = "AutoHubVehiclesApiSqs" # Novo nome base
}

variable "lambda_function_name" {
  description = "Nome base para a função Lambda da API de Veículos"
  type        = string
  default     = "AutoHubVehiclesApi"
}

variable "lambda_jar_path" {
  description = "OBRIGATÓRIO: Caminho para o JAR da API de Veículos"
  type        = string
}

# Variáveis para conexão com estados remotos
variable "terraform_state_bucket" {
  description = "Bucket com o tf state"
  type        = string
  default     = "vhc-terraform-state-autohub-clients-v1"
}

# Variáveis de configuração da Lambda

# Variáveis de memória/timeout podem ser específicas se necessário
variable "lambda_memory_size_http" {
  description = "Memória para a Lambda HTTP (MB)"
  type        = number
  default     = 1024
}
variable "lambda_timeout_http" {
  description = "Timeout da Lambda HTTP (segundos)"
  type        = number
  default     = 60
}

variable "lambda_memory_size_sqs" {
  description = "Memória para a Lambda SQS (MB)"
  type        = number
  default     = 1024
}

variable "lambda_timeout_sqs" {
  description = "Timeout da Lambda SQS (segundos) - Deve ser maior que o visibility timeout da fila"
  type        = number
  default     = 60
}

variable "lambda_runtime" {
  description = "Runtime Java"
  type        = string
  default     = "java21"
}

variable "lambda_handler_http" {
  description = "Handler da função Lambda HTTP (usando aws-serverless-java-container)"
  type        = string
  # Mantém o handler que você já tinha e funcionava para HTTP
  default = "com.fiap.autohub.autohub_vehicles_api.application.config.StreamLambdaHandler"
}

variable "lambda_handler_sqs" {
  description = "Handler da função Lambda SQS (usando RequestHandler ou FunctionInvoker)"
  type        = string
  # Handler que criaremos para SQS
  default = "org.springframework.cloud.function.adapter.aws.FunctionInvoker::handleRequest"
}