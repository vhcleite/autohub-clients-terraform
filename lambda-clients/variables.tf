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

variable "lambda_function_name" {
  description = "Nome base para a função Lambda da API de Clientes"
  type        = string
  default     = "AutoHubClientsApi" # Nome específico do serviço
}

variable "lambda_jar_path" {
  description = "OBRIGATÓRIO: Caminho para o JAR da API de Clientes"
  type        = string
}

variable "lambda_memory_size" {
  type    = number
  default = 1024
}
variable "lambda_timeout" {
  type    = number
  default = 60
}
variable "lambda_runtime" {
  type    = string
  default = "java17"
}
variable "lambda_handler" {
  description = "Handler da função Lambda (usando aws-serverless-java-container)"
  type        = string
  default     = "com.fiap.autohub.autohub_clients_api_java.application.config.StreamLambdaHandler"
}

variable "project_tags" {
  description = "Tags comuns para aplicar aos recursos"
  type        = map(string)
  default = {
    Project   = "AutoHub"
    Service   = "ClientsAPI"
    ManagedBy = "Terraform"
  }
}

variable "terraform_state_bucket" {
  description = "Bucket com o tf state"
  type        = string
  default     = "vhc-terraform-state-autohub-clients-v1"
}

variable "terraform_state_lock_table" {
  description = "dynamo db table com o lock do tf state"
  type        = string
  default     = "TerraformStateLockAutoHub"
}