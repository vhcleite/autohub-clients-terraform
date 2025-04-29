# terraform/rds-sales/outputs.tf
output "sales_db_instance_endpoint" {
  description = "Endereço (hostname) da instância RDS de Vendas"
  value       = aws_db_instance.sales_db.address
}

output "sales_db_instance_port" {
  description = "Porta da instância RDS de Vendas"
  value       = aws_db_instance.sales_db.port
}

output "sales_db_instance_name" {
  description = "Nome do banco de dados inicial criado"
  value       = aws_db_instance.sales_db.db_name # Ou use var.sales_db_name
}

output "sales_db_instance_username" {
  description = "Nome do usuário master do banco de dados"
  value       = aws_db_instance.sales_db.username # Ou use var.sales_db_username
}

output "sales_db_password_secret_arn" {
  description = "ARN do segredo no Secrets Manager contendo a senha master"
  value       = aws_secretsmanager_secret.db_password_secret.arn
}

output "sales_db_instance_arn" {
  description = "ARN da instância RDS de Vendas"
  value       = aws_db_instance.sales_db.arn
}

output "sales_db_security_group_id" {
  description = "ID do Security Group da instância RDS de Vendas"
  value       = aws_security_group.sales_db_sg.id
}

output "db_subnet_group_subnet_ids" {
  description = "Lista de IDs das subnets usadas pelo DB Subnet Group de Vendas"
  value       = aws_db_subnet_group.sales_db_subnet_group.subnet_ids
}