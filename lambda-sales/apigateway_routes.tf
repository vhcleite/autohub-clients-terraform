# terraform/lambda-sales/apigateway_routes.tf

# Integração entre API GW compartilhado e a Lambda HTTP DESTE serviço
resource "aws_apigatewayv2_integration" "sales_lambda_integration" {
  api_id                 = data.terraform_remote_state.api_gateway.outputs.api_gateway_id
  integration_type       = "AWS_PROXY"
  # Aponta para a Lambda HTTP
  integration_uri        = aws_lambda_function.sales_api_http_handler.invoke_arn
  payload_format_version = "2.0"
}

# Rota para capturar chamadas para /sales/*
resource "aws_apigatewayv2_route" "sales_proxy_route" { # Nome da rota atualizado para clareza
  api_id    = data.terraform_remote_state.api_gateway.outputs.api_gateway_id
  route_key = "ANY /sales/{proxy+}"
  # Aponta para a Integração HTTP
  target    = "integrations/${aws_apigatewayv2_integration.sales_lambda_integration.id}"
}

# Rota separada para a raiz /sales
resource "aws_apigatewayv2_route" "sales_base_route" { # Nome da rota atualizado para clareza
  api_id    = data.terraform_remote_state.api_gateway.outputs.api_gateway_id
  route_key = "ANY /sales"
  # Aponta para a Integração HTTP
  target    = "integrations/${aws_apigatewayv2_integration.sales_lambda_integration.id}"
}

# Permissão para API Gateway invocar a Lambda HTTP
resource "aws_lambda_permission" "sales_api_gw_permission" {
  statement_id  = "AllowAPIGatewayInvokeSalesAPI"
  action        = "lambda:InvokeFunction"
  # Aponta para a Lambda HTTP
  function_name = aws_lambda_function.sales_api_http_handler.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${data.terraform_remote_state.api_gateway.outputs.api_gateway_execution_arn}/*/*"
}
