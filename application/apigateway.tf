# --- API Gateway HTTP API ---
resource "aws_apigatewayv2_api" "http_api" {
  # Nome da API Gateway na AWS
  name = "${var.lambda_function_name}-${var.environment}-http-api"
  # Protocolo HTTP (mais simples e moderno que REST para proxy Lambda)
  protocol_type = "HTTP"
  description   = "API Gateway for ${var.lambda_function_name}"

  # Configuração de CORS (Cross-Origin Resource Sharing)
  # Permite que seu frontend (em outro domínio) chame esta API.
  # ATENÇÃO: '*' é muito permissivo para produção. Restrinja as origens!
  cors_configuration {
    allow_origins = ["*"] # Ex: ["https://seu-dominio-frontend.com"]
    allow_methods = ["GET", "POST", "PUT", "DELETE", "PATCH", "OPTIONS"]
    allow_headers = ["Content-Type", "Authorization", "X-Amz-Date", "X-Api-Key", "X-Amz-Security-Token"]
    max_age       = 300 # Cache da preflight request (OPTIONS) em segundos
  }

  tags = merge(
    var.project_tags,
    {
      Name        = "${var.lambda_function_name}-${var.environment}-http-api"
      Environment = var.environment
    }
  )
}

# --- Integração Lambda Proxy ---
# Define como o API Gateway se conecta à função Lambda.
resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id           = aws_apigatewayv2_api.http_api.id # ID da API criada acima
  integration_type = "AWS_PROXY"                      # Tipo de integração padrão para Lambda
  # URI de integração: Aponta para a função Lambda.
  # Usar 'invoke_arn' é recomendado, especialmente com versionamento/aliases/SnapStart.
  integration_uri        = aws_lambda_function.api_handler.invoke_arn
  payload_format_version = "2.0" # Formato do evento enviado para o Lambda
  timeout_milliseconds   = 29000 # Timeout da integração (max 29s para HTTP API sync)
}

# --- Rota Padrão ---
# Captura todas as requisições (qualquer método, qualquer path) e envia para a integração Lambda.
# O roteamento interno (ex: /users/me, /users/{id}) será feito pelo Spring Boot dentro do Lambda.
resource "aws_apigatewayv2_route" "default_proxy_route" {
  api_id = aws_apigatewayv2_api.http_api.id
  # '$default' é uma rota especial que captura qualquer requisição não correspondida por rotas mais específicas.
  route_key = "$default"
  # Define o alvo da rota como a integração Lambda criada acima.
  target = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"

  # --- NÃO PRECISA DE AUTORIZADOR AQUI ---
  # A autenticação/autorização será feita DENTRO do Lambda pelo Spring Security,
  # validando o token JWT que o cliente enviar no header 'Authorization'.
  # Se fôssemos usar o Authorizer do API Gateway, configuraríamos aqui:
  # authorization_type = "JWT"
  # authorizer_id      = aws_apigatewayv2_authorizer.cognito_jwt_authorizer.id
}

# --- Stage de Deploy ---
# Um Stage representa um snapshot da sua API que pode ser invocado (ex: dev, prod).
resource "aws_apigatewayv2_stage" "api_stage" {
  api_id = aws_apigatewayv2_api.http_api.id
  # '$default' cria um stage padrão que é acessível diretamente na URL base da API.
  # Você pode criar stages nomeados (ex: "v1", "dev", "prod").
  name = "$default"
  # Habilita deploy automático sempre que a API for modificada (conveniente para dev).
  auto_deploy = true

  # Configurações de log de acesso para o API Gateway (opcional, mas útil)
  # Requer um Log Group do CloudWatch (definido abaixo ou existente)
  # access_log_settings {
  #   destination_arn = aws_cloudwatch_log_group.api_gw_logs.arn
  #   format = jsonencode({ /* ... formato do log ... */ })
  # }

  tags = merge(
    var.project_tags,
    {
      Name        = "${var.lambda_function_name}-${var.environment}-stage"
      Environment = var.environment
    }
  )

  # Para apontar para um Alias específico do Lambda (ver Versionamento):
  # default_route_settings {
  #   throttling_burst_limit = 5000 # Exemplo de throttling
  #   throttling_rate_limit  = 10000
  # }
  # stage_variables = {
  #   lambdaAlias = "prod" # Exemplo de variável de stage
  # }
  # A integração precisaria usar a variável: integration_uri = "${aws_lambda_function.api_handler.invoke_arn}:${stageVariables.lambdaAlias}"
}

/* # Opcional: Log Group para o API Gateway Access Logs
resource "aws_cloudwatch_log_group" "api_gw_logs" {
  name              = "/aws/apigateway/${var.lambda_function_name}-${var.environment}-http-api"
  retention_in_days = 7

  tags = merge(var.project_tags, { Environment = var.environment })
}
*/