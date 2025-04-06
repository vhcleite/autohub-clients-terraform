output "dynamodb_user_table_name" {
  description = "The name of the DynamoDB user table"
  value       = aws_dynamodb_table.user_table.name
}

output "dynamodb_user_table_arn" {
  description = "The ARN of the DynamoDB user table"
  value       = aws_dynamodb_table.user_table.arn
}

output "dynamodb_user_table_email_index_name" {
  description = "The name of the email Global Secondary Index"
  value       = [for gsi in aws_dynamodb_table.user_table.global_secondary_index : gsi.name if gsi.name == "email-index"][0]
}