# terraform/messaging/outputs.tf

output "main_event_topic_arn" {
  description = "ARN do Tópico SNS principal para eventos de negócio"
  value       = aws_sns_topic.main_bus.arn
}

# --- Outputs da Fila de Timeout ---
output "charge_timeout_queue_url" {
  description = "URL da fila SQS para timeout de pagamento"
  value       = aws_sqs_queue.charge_timeout_queue.id
}
output "charge_timeout_queue_arn" {
  description = "ARN da fila SQS para timeout de pagamento"
  value       = aws_sqs_queue.charge_timeout_queue.arn
}
output "charge_timeout_dlq_arn" {
  description = "ARN da DLQ da fila de timeout de pagamento"
  value       = aws_sqs_queue.charge_timeout_dlq.arn
}


# --- Outputs das Filas de Eventos (Gerados com for_each) ---
# Exporta um mapa contendo ARN e URL para cada fila principal de evento
output "event_queues_arns" {
  description = "Mapa com os ARNs das filas SQS principais de eventos (chave = nome lógico)"
  value       = { for k, queue in aws_sqs_queue.event_queues : k => queue.arn }
}
output "event_queues_urls" {
  description = "Mapa com as URLs das filas SQS principais de eventos (chave = nome lógico)"
  value       = { for k, queue in aws_sqs_queue.event_queues : k => queue.id }
}

# Exporta um mapa contendo os ARNs das DLQs de eventos
output "event_dlqs_arns" {
  description = "Mapa com os ARNs das DLQs de eventos (chave = nome lógico)"
  value       = { for k, dlq in aws_sqs_queue.event_dlqs : k => dlq.arn }
}

output "vehicles_sale_created_queue_name" {
  description = "Nome da fila SQS para a Vehicles API processar SaleCreated"
  value = element(split(":", aws_sqs_queue.event_queues["vehicles_on_sale_created"].arn), 5)
}