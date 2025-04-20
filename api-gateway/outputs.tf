output "api_gateway_id" {
  description = "ID da API Gateway HTTP API compartilhada"
  value       = aws_apigatewayv2_api.shared_http_api.id
}

output "api_gateway_execution_arn" {
  description = "Execution ARN da API Gateway (para permissões Lambda)"
  # Formato: arn:aws:execute-api:region:account-id:api-id
  value = aws_apigatewayv2_api.shared_http_api.execution_arn
}

output "api_stage_invoke_url" {
  description = "URL de invocação completa do stage $default (URL base da API)"
  value       = aws_apigatewayv2_stage.default_stage.invoke_url
}