# --- Fila de Timeout de Cobrança e sua DLQ ---
resource "aws_sqs_queue" "charge_timeout_dlq" {
  name                      = "${var.charge_timeout_dlq_name}-${var.environment}"
  message_retention_seconds = var.sqs_message_retention_seconds # Ex: 14 dias para DLQ
  tags                      = merge(var.project_tags, { Name = "${var.charge_timeout_dlq_name}-${var.environment}" })
}

resource "aws_sqs_queue" "charge_timeout_queue" {
  name                       = "${var.charge_timeout_queue_name}-${var.environment}"
  visibility_timeout_seconds = var.charge_timeout_visibility_seconds # Tempo para Lambda de cancelamento processar
  message_retention_seconds  = var.sqs_message_retention_seconds

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.charge_timeout_dlq.arn
    maxReceiveCount     = var.sqs_max_receive_count
  })

  tags = merge(var.project_tags, { Name = "${var.charge_timeout_queue_name}-${var.environment}" })
}


# --- Filas para Consumidores de Eventos de Negócio (Padrão Fan-out SNS->SQS) ---

locals {
  # Define os pares de Fila Principal + DLQ
  event_queues = {
    # Nome do Par : Prefixo do Nome da Fila
    "charges_on_vehicle_reserved" = "ChargesApi_VehicleReserved"
    "vehicles_events"             = "VehiclesApi_Events"
    "sales_on_events"             = "SalesApi_Events"
  }
}

# Cria as DLQs para cada par definido em local.event_queues
resource "aws_sqs_queue" "event_dlqs" {
  for_each                  = local.event_queues
  name                      = "${each.value}_DLQ-${var.environment}"
  message_retention_seconds = 1209600 # 14 dias para DLQs
  tags = merge(
    var.project_tags,
    {
      Name         = "${each.value}_DLQ-${var.environment}"
      Environment  = var.environment
      ConsumesFrom = aws_sns_topic.main_bus.name
    }
  )
}

# Cria as Filas Principais para cada par, com redrive para a DLQ correspondente
resource "aws_sqs_queue" "event_queues" {
  for_each                   = local.event_queues
  name                       = "${each.value}_Queue-${var.environment}"
  visibility_timeout_seconds = 130
  message_retention_seconds  = var.sqs_message_retention_seconds

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.event_dlqs[each.key].arn
    maxReceiveCount     = var.sqs_max_receive_count
  })

  depends_on = [aws_sns_topic.main_bus]

  tags = merge(
    var.project_tags,
    {
      Name         = "${each.value}_Queue-${var.environment}"
      Environment  = var.environment
      ConsumesFrom = aws_sns_topic.main_bus.name
    }
  )
}
