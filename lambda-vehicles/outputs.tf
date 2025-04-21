output "lambda_function_name" {
  description = "Nome da função Lambda da API de Veículos"
  value       = aws_lambda_function.vehicles_api_handler.function_name
}

output "lambda_function_arn" {
  description = "ARN da função Lambda da API de Veículos"
  value       = aws_lambda_function.vehicles_api_handler.arn
}

output "lambda_security_group_id" {
  description = "ID do Security Group criado para a Lambda de Veículos"
  value       = aws_security_group.vehicles_lambda_sg.id
}