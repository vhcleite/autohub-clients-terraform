# terraform/lambda-sales/variables.tf

variable "aws_region" { default = "us-east-1" }
variable "environment" { default = "dev" }
variable "project_tags" {
  type    = map(string)
  default = { Project = "AutoHub", Service = "SalesApi", ManagedBy = "Terraform" }
}

variable "lambda_function_name" { default = "AutoHubSalesApi" }
variable "lambda_jar_path" { type = string }

variable "lambda_memory_size" { default = 1024 }
variable "lambda_timeout" { default = 60 }
variable "lambda_runtime" { default = "java21" }
variable "lambda_handler" {
  description = "Handler para Sales API (usando aws-serverless-java-container)"
  type        = string
  default     = "com.fiap.autohub.autohub_sales_api.application.config.StreamLambdaHandler"
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

variable "vpc_id" {
  description = "ID da VPC onde o RDS e SGs serão criados"
  type        = string
}