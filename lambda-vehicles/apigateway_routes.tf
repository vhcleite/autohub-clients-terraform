# terraform/lambda-vehicles/apigateway_routes.tf

resource "aws_apigatewayv2_integration" "vehicles_lambda_integration" { # Nome atualizado
  api_id           = data.terraform_remote_state.api_gateway.outputs.api_gateway_id
  integration_type = "AWS_PROXY"
  # Aponta para a Lambda HTTP
  integration_uri        = aws_lambda_function.vehicles_api_http_handler.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "vehicles_proxy_route" {
  api_id    = data.terraform_remote_state.api_gateway.outputs.api_gateway_id
  route_key = "ANY /vehicles/{proxy+}"
  # Aponta para a Integração HTTP
  target = "integrations/${aws_apigatewayv2_integration.vehicles_lambda_integration.id}"
}

resource "aws_apigatewayv2_route" "vehicles_base_route" {
  api_id    = data.terraform_remote_state.api_gateway.outputs.api_gateway_id
  route_key = "ANY /vehicles"
  # Aponta para a Integração HTTP
  target = "integrations/${aws_apigatewayv2_integration.vehicles_lambda_integration.id}"
}

# Permissão para API Gateway invocar a Lambda HTTP
resource "aws_lambda_permission" "vehicles_api_gw_permission" {
  statement_id = "AllowAPIGatewayInvokeVehiclesAPI"
  action       = "lambda:InvokeFunction"
  # Aponta para a Lambda HTTP
  function_name = aws_lambda_function.vehicles_api_http_handler.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${data.terraform_remote_state.api_gateway.outputs.api_gateway_execution_arn}/*/*"
}
