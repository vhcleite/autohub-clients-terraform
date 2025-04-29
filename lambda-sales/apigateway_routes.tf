# terraform/lambda-sales/apigateway_routes.tf

# Integração entre API GW compartilhado e a Lambda DESTE serviço
resource "aws_apigatewayv2_integration" "sales_lambda_integration" {
  api_id                 = data.terraform_remote_state.api_gateway.outputs.api_gateway_id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.sales_api_handler.invoke_arn # ARN desta Lambda
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "clients_proxy_route" {
  api_id = data.terraform_remote_state.api_gateway.outputs.api_gateway_id
  route_key = "ANY /sales/{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.sales_lambda_integration.id}"
}

resource "aws_apigatewayv2_route" "clients_base_route" {
  api_id    = data.terraform_remote_state.api_gateway.outputs.api_gateway_id
  route_key = "ANY /sales"
  target    = "integrations/${aws_apigatewayv2_integration.sales_lambda_integration.id}"
}