# terraform/cognito/variables.tf

variable "aws_region" {
  description = "Região AWS onde o Cognito User Pool será criado"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Ambiente de deploy (ex: dev, staging, prod) usado para nomear recursos"
  type        = string
  default     = "dev"
}

variable "user_pool_base_name" {
  description = "Nome base para o Cognito User Pool"
  type        = string
  default     = "vehicle-resale-user-pool"
}

variable "user_pool_domain_prefix" {
  description = "Prefixo único para o domínio da Hosted UI do Cognito"
  type        = string
  default     = "fiap-autohub-clients"
}

variable "app_client_name" {
  description = "Nome base para o App Client do Cognito"
  type        = string
  default     = "vehicle-resale-app-client"
}

// Mantendo as tags como variável para consistência
variable "project_tags" {
  description = "Tags comuns para aplicar aos recursos"
  type        = map(string)
  default = {
    Project   = "AutoHub"
    Service   = "Cognito"
    ManagedBy = "Terraform"
  }
}

variable "app_client_callback_urls" {
  description = "Lista de URLs de Callback permitidas para o App Client"
  type        = list(string)
  default     = ["https://jwt.io"]
}

variable "app_client_logout_urls" {
  description = "Lista de URLs de Logout permitidas para o App Client"
  type        = list(string)
  default     = ["https://jwt.io/logout"]
}

// Variável para escopos OAuth permitidos
variable "app_client_oauth_scopes" {
  description = "Lista de escopos OAuth permitidos para o App Client"
  type        = list(string)
  default     = ["openid", "email", "profile"] // Manter profile por enquanto
}

// Variável para fluxos OAuth permitidos
variable "app_client_oauth_flows" {
  description = "Lista de fluxos OAuth permitidos ('code', 'implicit', 'client_credentials')"
  type        = list(string)
  default     = ["code", "implicit"] // Manter implicit por enquanto
}