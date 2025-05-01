output "charges_table_name" {
  description = "Nome da tabela DynamoDB de Cobranças"
  value       = aws_dynamodb_table.charges_table.name
}

output "charges_table_arn" {
  description = "ARN da tabela DynamoDB de Cobranças"
  value       = aws_dynamodb_table.charges_table.arn
}

output "gsi_sale_id_name" {
  description = "Nome do Índice Secundário Global (GSI) por sale_id"
  value       = var.gsi_sale_id_name
}

output "gsi_sale_id_arn" {
  description = "ARN do Índice Secundário Global (GSI) por sale_id"
  value       = "${aws_dynamodb_table.charges_table.arn}/index/${var.gsi_sale_id_name}"
}
