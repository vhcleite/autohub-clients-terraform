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
    Service   = "VehiclesApi" # Tag genérica para o serviço
    ManagedBy = "Terraform"
  }
}

# --- Variáveis para Lambda HTTP ---
variable "lambda_function_name_http" {
  description = "Nome base para a função Lambda da API HTTP de Veículos"
  type        = string
  default     = "AutoHubVehiclesApiHttp"
}

variable "lambda_handler_http" {
  description = "Handler da função Lambda HTTP"
  type        = string
  default     = "com.fiap.autohub.autohub_vehicles_api.application.config.StreamLambdaHandler"
}

variable "lambda_function_name" {
  description = "Nome base para a função Lambda da API de Veículos"
  type        = string
  default     = "AutoHubVehiclesApi"
}

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

# --- Variáveis para Lambda SQS (ÚNICA) ---
variable "lambda_function_name_sqs" {
  description = "Nome base para a função Lambda do Listener SQS de Veículos"
  type        = string
  default     = "AutoHubVehiclesApiSqs"
}

variable "lambda_handler_sqs" {
  description = "Handler da função Lambda SQS (usando FunctionInvoker)"
  type        = string
  default     = "org.springframework.cloud.function.adapter.aws.FunctionInvoker"
}

variable "lambda_memory_size_sqs" {
  description = "Memória para a Lambda SQS (MB)"
  type        = number
  default     = 1024
}
variable "lambda_timeout_sqs" {
  description = "Timeout da Lambda SQS (segundos) - Deve ser >= Queue Visibility Timeout"
  type        = number
  default     = 130 # Ajustado para corresponder ao timeout da fila no messaging/sqs.tf
}

# --- Variáveis Comuns ---
variable "lambda_jar_path" {
  description = "OBRIGATÓRIO: Caminho para o JAR da API de Veículos (Fat JAR)"
  type        = string
}

variable "lambda_runtime" {
  description = "Runtime Java"
  type        = string
  default     = "java21"
}

variable "terraform_state_bucket" {
  description = "Bucket S3 com os estados remotos do Terraform"
  type        = string
  default     = "vhc-terraform-state-autohub-clients-v1"
}

variable "terraform_state_lock_table" {
  description = "Tabela DynamoDB para lock do estado Terraform"
  type        = string
  default     = "TerraformStateLockAutoHub"
}

