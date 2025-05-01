# Integração entre API GW compartilhado e a Lambda HTTP da Charges API
resource "aws_apigatewayv2_integration" "charges_lambda_http_integration" {
  api_id           = data.terraform_remote_state.api_gateway.outputs.api_gateway_id
  integration_type = "AWS_PROXY"
  # Aponta para a Lambda HTTP
  integration_uri        = aws_lambda_function.charges_api_http_handler.invoke_arn
  payload_format_version = "2.0"
  # Timeout pode ser configurado aqui também, se diferente do default de 30s
  # timeout_milliseconds = 29000
}

# Rota para o callback do gateway de pagamento
resource "aws_apigatewayv2_route" "charges_callback_route" {
  api_id = data.terraform_remote_state.api_gateway.outputs.api_gateway_id
  route_key = "ANY /charges/{proxy+}"
  target = "integrations/${aws_apigatewayv2_integration.charges_lambda_http_integration.id}"
}

# Rota para buscar cobrança por ID da venda (se implementado)
resource "aws_apigatewayv2_route" "charges_get_by_sale_route" {
  api_id    = data.terraform_remote_state.api_gateway.outputs.api_gateway_id
  route_key = "ANY /charges"
  target    = "integrations/${aws_apigatewayv2_integration.charges_lambda_http_integration.id}"
}


# Permissão para API Gateway invocar a Lambda HTTP
resource "aws_lambda_permission" "charges_api_gw_permission" {
  statement_id = "AllowAPIGatewayInvokeChargesAPI"
  action       = "lambda:InvokeFunction"
  # Aponta para a Lambda HTTP
  function_name = aws_lambda_function.charges_api_http_handler.function_name
  principal     = "apigateway.amazonaws.com"
  # Restringe a origem à API Gateway específica e aos métodos/paths definidos
  source_arn = "${data.terraform_remote_state.api_gateway.outputs.api_gateway_execution_arn}/*/*" # Pode restringir mais
}
