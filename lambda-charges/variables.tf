variable "aws_region" {
  description = "Região AWS"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Ambiente de deploy (ex: dev)"
  type        = string
  default     = "dev"
}

variable "project_tags" {
  description = "Tags comuns para aplicar aos recursos"
  type        = map(string)
  default = {
    Project   = "AutoHub"
    Service   = "ChargesApi"
    ManagedBy = "Terraform"
  }
}

# --- Variáveis para Lambda HTTP ---
variable "lambda_function_name_http" {
  description = "Nome base para a função Lambda da API HTTP de Cobranças"
  type        = string
  default     = "AutoHubChargesApiHttp"
}

variable "lambda_handler_http" {
  description = "Handler da função Lambda HTTP (usando aws-serverless-java-container)"
  type        = string
  default     = "com.fiap.autohub.autohub_charges_api.application.config.StreamLambdaHandler"
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

# --- Variáveis para Lambda SQS ---
variable "lambda_function_name_sqs" {
  description = "Nome base para a função Lambda do Listener SQS de Cobranças"
  type        = string
  default     = "AutoHubChargesApiSqs"
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
  default     = 60
}

# --- Variáveis Comuns ---
variable "lambda_jar_path" {
  description = "OBRIGATÓRIO: Caminho para o JAR da API de Cobranças (Fat JAR)"
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

