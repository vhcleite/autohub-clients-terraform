# terraform/database-clients/outputs.tf

output "dynamodb_user_table_name" {
  description = "O nome da tabela DynamoDB criada para usuários/clientes"
  value       = aws_dynamodb_table.user_table.name
}

output "dynamodb_user_table_arn" {
  description = "O ARN (Amazon Resource Name) da tabela DynamoDB de usuários/clientes"
  value       = aws_dynamodb_table.user_table.arn
}

output "dynamodb_user_table_email_index_name" {
  description = "O nome do Índice Secundário Global (GSI) baseado no email"
  value       = [for gsi in aws_dynamodb_table.user_table.global_secondary_index : gsi.name if gsi.name == "email-index"][0]
}