output "vehicles_db_instance_endpoint" {
  description = "Endereço (hostname) da instância RDS de Veículos"
  value       = aws_db_instance.vehicles_db.address
}

output "vehicles_db_instance_port" {
  description = "Porta da instância RDS de Veículos"
  value       = aws_db_instance.vehicles_db.port
}

output "vehicles_db_instance_name" {
  description = "Nome do banco de dados inicial criado"
  value       = aws_db_instance.vehicles_db.db_name
}

output "vehicles_db_instance_username" {
  description = "Nome do usuário master do banco de dados"
  value       = aws_db_instance.vehicles_db.username
}

output "vehicles_db_password_secret_arn" {
  description = "ARN do segredo no Secrets Manager contendo a senha master"
  value       = aws_secretsmanager_secret.db_password_secret.arn
}

output "vehicles_db_instance_arn" {
  description = "ARN da instância RDS de Veículos"
  value       = aws_db_instance.vehicles_db.arn
}

output "vehicles_db_security_group_id" {
  description = "ID do Security Group da instância RDS de Veículos"
  value       = aws_security_group.vehicles_db_sg.id
}

output "db_subnet_group_subnet_ids" {
  description = "Lista de subnet IDs usados pelo DB subnet group de Veículos"
  value       = aws_db_subnet_group.vehicles_db_subnet_group.subnet_ids
}