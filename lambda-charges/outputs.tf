output "lambda_function_name_http" {
  description = "Nome da função Lambda da API HTTP de Cobranças"
  value       = aws_lambda_function.charges_api_http_handler.function_name
}

output "lambda_function_arn_http" {
  description = "ARN da função Lambda da API HTTP de Cobranças"
  value       = aws_lambda_function.charges_api_http_handler.arn
}

output "lambda_function_name_sqs" {
  description = "Nome da função Lambda do Listener SQS de Cobranças"
  value       = aws_lambda_function.charges_api_sqs_handler.function_name
}

output "lambda_function_arn_sqs" {
  description = "ARN da função Lambda do Listener SQS de Cobranças"
  value       = aws_lambda_function.charges_api_sqs_handler.arn
}
