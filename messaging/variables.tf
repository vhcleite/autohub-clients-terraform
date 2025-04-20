variable "aws_region" {
  description = "Região AWS onde os recursos de mensageria serão criados"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Ambiente de deploy (ex: dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "project_tags" {
  description = "Tags comuns para aplicar aos recursos"
  type        = map(string)
  default = {
    Project   = "AutoHub"
    Service   = "Messaging"
    ManagedBy = "Terraform"
  }
}

variable "main_sns_topic_name" {
  description = "Nome do tópico SNS principal para eventos de negócio"
  type        = string
  default     = "AutoHubBusinessEvents"
}

variable "sqs_max_receive_count" {
  description = "Número máximo de vezes que uma mensagem SQS é recebida antes de ir para DLQ"
  type        = number
  default     = 3
}

variable "sqs_message_retention_seconds" {
  description = "Tempo em segundos que a SQS guarda a mensagem (Max 14 dias)"
  type        = number
  default     = 345600 # 4 dias (padrão SQS)
}

variable "charge_timeout_visibility_seconds" {
  description = "Tempo (segundos) que a msg de timeout fica invisível após ser pega pelo Lambda"
  type        = number
  default     = 60
}

variable "charge_timeout_queue_name" {
  description = "Nome base para a fila SQS de timeout de cobrança"
  type        = string
  default     = "AutoHubChargeTimeoutQueue"
}

variable "charge_timeout_dlq_name" {
  description = "Nome base para a DLQ da fila de timeout"
  type        = string
  default     = "AutoHubChargeTimeoutQueue-DLQ"
}