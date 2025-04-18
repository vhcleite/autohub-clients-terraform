output "lambda_function_name" {
  description = "Nome da função Lambda da API de Clientes"
  value       = aws_lambda_function.clients_api_handler.function_name
}
output "lambda_function_arn" {
  description = "ARN da função Lambda da API de Clientes"
  value       = aws_lambda_function.clients_api_handler.arn
}