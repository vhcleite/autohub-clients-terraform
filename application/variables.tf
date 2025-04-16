variable "aws_region" {
  description = "Região AWS onde os recursos serão criados"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Ambiente de deploy (ex: dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "lambda_function_name" {
  description = "Nome base para a função Lambda e recursos relacionados"
  type        = string
  default     = "AutoHubClientsApi"
}

variable "lambda_memory_size" {
  description = "Memória alocada para a função Lambda (MB)"
  type        = number
  default     = 2048
}

variable "lambda_timeout" {
  description = "Tempo máximo de execução da função Lambda (segundos)"
  type        = number
  default     = 30 # API Gateway tem timeout de 29s, então 60s é seguro aqui
}

variable "lambda_runtime" {
  description = "Runtime Java para o Lambda"
  type        = string
  default     = "java17"
}

variable "lambda_handler" {
  description = "Handler do Spring Cloud Function Adapter"
  type        = string
  # default     = "org.springframework.cloud.function.adapter.aws.FunctionInvoker::handleRequest"
    # default     = "org.springframework.cloud.function.adapter.aws.SpringBootApiGatewayRequestHandler"
  default     = "com.fiap.autohub.autohub_clients_api_java.application.config.StreamLambdaHandler"
  
}

variable "lambda_jar_path" {
  description = "Caminho OBRIGATÓRIO para o arquivo .jar da aplicação Spring Boot a ser implantado"
  type        = string
  # Não coloque default aqui! Forçará o usuário a passar via linha de comando ou .tfvars
  # Exemplo de como passar: -var="lambda_jar_path=../../autohub-clients-api/build/libs/autohub-clients-api-0.0.1-SNAPSHOT.jar"
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