# Integração entre API GW compartilhado e a Lambda DESTE serviço
resource "aws_apigatewayv2_integration" "vehicles_lambda_integration" {
  api_id                 = data.terraform_remote_state.api_gateway.outputs.api_gateway_id # ID da API compartilhada
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.vehicles_api_handler.invoke_arn # ARN desta Lambda
  payload_format_version = "2.0"
}

# Rota para capturar chamadas para /vehicles/*
resource "aws_apigatewayv2_route" "vehicles_proxy_route" {
  api_id = data.terraform_remote_state.api_gateway.outputs.api_gateway_id
  # Rota curinga para /vehicles e tudo abaixo (ex: /vehicles/123, /vehicles/status/available)
  route_key = "ANY /vehicles/{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.vehicles_lambda_integration.id}" # Integração desta Lambda
  # Autorização tratada pelo Spring Security
}

# Rota separada para a raiz /vehicles se precisar de ações como POST
resource "aws_apigatewayv2_route" "vehicles_base_route" {
  api_id    = data.terraform_remote_state.api_gateway.outputs.api_gateway_id
  route_key = "ANY /vehicles"                                                               # Permite POST /vehicles, GET /vehicles, etc.
  target    = "integrations/${aws_apigatewayv2_integration.vehicles_lambda_integration.id}" # Integração desta Lambda
}