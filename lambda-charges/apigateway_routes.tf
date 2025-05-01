resource "aws_apigatewayv2_integration" "charges_lambda_http_integration" { # Nome pode ser mantido ou atualizado
  api_id                 = data.terraform_remote_state.api_gateway.outputs.api_gateway_id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_alias.charges_http_alias_live.invoke_arn
  payload_format_version = "2.0"
}

# Rota para capturar chamadas para /charges/*
resource "aws_apigatewayv2_route" "charges_proxy_route" { # Nome pode ser mantido ou atualizado
  api_id    = data.terraform_remote_state.api_gateway.outputs.api_gateway_id
  route_key = "ANY /charges/{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.charges_lambda_http_integration.id}"
}

# Rota separada para a raiz /charges
resource "aws_apigatewayv2_route" "charges_base_route" { # Nome pode ser mantido ou atualizado
  api_id    = data.terraform_remote_state.api_gateway.outputs.api_gateway_id
  route_key = "ANY /charges"
  target    = "integrations/${aws_apigatewayv2_integration.charges_lambda_http_integration.id}"
}

# Permissão para API Gateway invocar o ALIAS da Lambda HTTP
resource "aws_lambda_permission" "charges_api_gw_permission" {
  statement_id  = "AllowAPIGatewayInvokeChargesAPI"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_alias.charges_http_alias_live.arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${data.terraform_remote_state.api_gateway.outputs.api_gateway_execution_arn}/*/*"
}