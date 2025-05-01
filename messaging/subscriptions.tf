# --- Assinaturas SNS -> SQS com Filtros ---

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

# Assinatura para enviar TODOS os eventos relevantes para a fila única da Vehicles API
resource "aws_sns_topic_subscription" "vehicles_events_sub" {
  topic_arn            = aws_sns_topic.main_bus.arn
  protocol             = "sqs"
  endpoint             = aws_sqs_queue.event_queues["vehicles_events"].arn
  raw_message_delivery = true
  filter_policy = jsonencode({
    eventType = [
      "SaleCreated", # Para iniciar a reserva
      "PaymentCompleted", # Para marcar como vendido
      "PaymentFailed", # Para cancelar reserva
      "ChargeCreationFailed", # Para cancelar reserva
      "ChargeExpired" # Para cancelar reserva
    ]
  })
}

# Assinatura para enviar eventos relevantes para a fila da Sales API (Mantém)
resource "aws_sns_topic_subscription" "sales_events_sub" {
  topic_arn            = aws_sns_topic.main_bus.arn
  protocol             = "sqs"
  endpoint             = aws_sqs_queue.event_queues["sales_on_events"].arn
  raw_message_delivery = true
  filter_policy = jsonencode({
    eventType = [
      "VehicleReservationFailed",
      "ChargeCreationFailed",
      "PaymentCompleted",
      "PaymentFailed",
      "ChargeExpired"
    ]
  })
}


# --- Permissões para SNS publicar nas Filas SQS ---

data "aws_iam_policy_document" "sqs_allow_sns_policy" {
  for_each = aws_sqs_queue.event_queues

  statement {
    sid     = "AllowSNSPublish-${each.key}"
    effect  = "Allow"
    actions = ["sqs:SendMessage"]
    resources = [
      each.value.arn
    ]
    principals {
      type        = "Service"
      identifiers = ["sns.amazonaws.com"]
    }
    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values   = [aws_sns_topic.main_bus.arn]
    }
  }
}

resource "aws_sqs_queue_policy" "event_queues_policy" {
  for_each  = aws_sqs_queue.event_queues
  queue_url = each.value.id
  policy    = data.aws_iam_policy_document.sqs_allow_sns_policy[each.key].json
}
