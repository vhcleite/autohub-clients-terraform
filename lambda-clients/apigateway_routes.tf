# Integração entre API GW e a Lambda DESTE serviço
resource "aws_apigatewayv2_integration" "clients_lambda_integration" {
  api_id = data.terraform_remote_state.api_gateway.outputs.api_gateway_id # ID da API compartilhada

  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.clients_api_handler.invoke_arn # ARN desta Lambda
  payload_format_version = "2.0"
}

# Rota para capturar chamadas para /users/* (exemplo)
resource "aws_apigatewayv2_route" "clients_proxy_route" {
  api_id = data.terraform_remote_state.api_gateway.outputs.api_gateway_id
  # Define que qualquer requisição começando com /users vai para esta integração
  # O {proxy+} captura o resto do path
  route_key = "ANY /users/{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.clients_lambda_integration.id}"
  # Sem autorizador aqui, Spring Security trata
}

# Rota separada para /users (sem o proxy+) se necessário
resource "aws_apigatewayv2_route" "clients_base_route" {
  api_id    = data.terraform_remote_state.api_gateway.outputs.api_gateway_id
  route_key = "ANY /users" # Ex: para o POST /users
  target    = "integrations/${aws_apigatewayv2_integration.clients_lambda_integration.id}"
}