variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "us-east-1"
}

variable "dynamodb_table_name" {
  description = "Base name for the DynamoDB user table"
  type        = string
  default     = "AutoHubUsers"
}

variable "environment" {
  description = "Deployment environment (e.g., dev, staging, prod)"
  type        = string
  default     = "prod"
}

variable "project_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default = {
    Project   = "AutoHub"
    ManagedBy = "Terraform"
  }
}