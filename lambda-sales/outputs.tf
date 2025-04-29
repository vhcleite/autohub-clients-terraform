# terraform/lambda-sales/outputs.tf

output "lambda_function_name" {
  value = aws_lambda_function.sales_api_handler.function_name
}
output "lambda_function_arn" {
  value = aws_lambda_function.sales_api_handler.arn
}