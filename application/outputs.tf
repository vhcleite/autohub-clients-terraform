output "http_api_endpoint" {
  description = "URL base para invocar a API Gateway HTTP API"
  # A URL de invocação do stage '$default'
  value = aws_apigatewayv2_stage.api_stage.invoke_url
}

output "lambda_function_name" {
  description = "Nome da função Lambda criada"
  value       = aws_lambda_function.api_handler.function_name
}

output "lambda_function_arn" {
  description = "ARN da função Lambda criada"
  value       = aws_lambda_function.api_handler.arn
}

output "lambda_exec_role_arn" {
  description = "ARN da Role IAM de execução do Lambda"
  value       = aws_iam_role.lambda_exec_role.arn
}