# terraform/messaging/subscriptions.tf

# --- Assinaturas SNS -> SQS com Filtros ---

resource "aws_sns_topic_subscription" "vehicles_sale_created_sub" {
  topic_arn            = aws_sns_topic.main_bus.arn
  protocol             = "sqs"
  endpoint             = aws_sqs_queue.event_queues["vehicles_on_sale_created"].arn
  raw_message_delivery = true # Envia apenas o corpo JSON do evento

  # Filtra para receber apenas eventos com eventType = "SaleCreated"
  filter_policy = jsonencode({
    eventType = ["SaleCreated"]
  })
}

# Assinatura para enviar eventos 'VehicleReserved' para a fila da Charges API
resource "aws_sns_topic_subscription" "charges_vehicle_reserved_sub" {
  topic_arn            = aws_sns_topic.main_bus.arn
  protocol             = "sqs"
  endpoint             = aws_sqs_queue.event_queues["charges_on_vehicle_reserved"].arn
  raw_message_delivery = true
  filter_policy = jsonencode({
    eventType = ["VehicleReserved"]
  })
}

# Assinatura para enviar eventos de Pagamento para a fila da Vehicles API (compensação/finalização)
resource "aws_sns_topic_subscription" "vehicles_payment_sub" {
  topic_arn            = aws_sns_topic.main_bus.arn
  protocol             = "sqs"
  endpoint             = aws_sqs_queue.event_queues["vehicles_on_payment"].arn
  raw_message_delivery = true
  filter_policy = jsonencode({
    # Ouve múltiplos eventos relacionados a pagamento ou falha na cobrança
    eventType = [
      "PaymentCompleted",
      "PaymentFailed",
      "ChargeCreationFailed", # Se a cobrança falhar ao ser criada
      "ChargeExpired"         # Se o pagamento expirar (publicado pela Lambda de timeout)
    ]
  })
}

# Assinatura para enviar eventos relevantes para a fila da Sales API
resource "aws_sns_topic_subscription" "sales_events_sub" {
  topic_arn            = aws_sns_topic.main_bus.arn
  protocol             = "sqs"
  endpoint             = aws_sqs_queue.event_queues["sales_on_events"].arn
  raw_message_delivery = true
  filter_policy = jsonencode({
    # Ouve múltiplos eventos para atualizar status ou compensar
    eventType = [
      "VehicleReservationFailed", # Falha na reserva
      "ChargeCreationFailed",     # Falha na cobrança
      "PaymentCompleted",         # Pagamento OK -> chamar DETRAN, finalizar
      "PaymentFailed",            # Pagamento Falhou -> cancelar venda
      "ChargeExpired"             # Pagamento Expirou -> cancelar venda
    ]
  })
}


# --- Permissões para SNS publicar nas Filas SQS ---

# Data source para gerar a política baseada nos ARNs das filas criadas
# Isso evita repetir a mesma estrutura de política várias vezes
data "aws_iam_policy_document" "sqs_allow_sns_policy" {
  # Cria uma declaração de política para CADA fila definida em local.event_queues
  for_each = aws_sqs_queue.event_queues # Itera sobre as filas principais criadas

  statement {
    sid     = "AllowSNSPublish-${each.key}" # ID único por statement
    effect  = "Allow"
    actions = ["sqs:SendMessage"]
    resources = [
      each.value.arn # ARN da fila atual no loop
    ]
    principals {
      type        = "Service"
      identifiers = ["sns.amazonaws.com"]
    }
    # Condição para garantir que SÓ o nosso tópico SNS pode enviar
    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values   = [aws_sns_topic.main_bus.arn]
    }
  }
}

# Aplica a política gerada a CADA fila SQS principal
resource "aws_sqs_queue_policy" "event_queues_policy" {
  for_each  = aws_sqs_queue.event_queues                                       # Itera sobre as filas principais
  queue_url = each.value.id                                                    # URL da fila atual
  policy    = data.aws_iam_policy_document.sqs_allow_sns_policy[each.key].json # Pega a política correta gerada para esta fila
}