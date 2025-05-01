# Trigger SQS -> Lambda SQS (para evento VehicleReserved)

resource "aws_lambda_event_source_mapping" "charges_vehicle_reserved_trigger" {
  # ARN da fila SQS de eventos da Charges API (VehicleReserved)
  # Certifique-se que a chave "charges_on_vehicle_reserved" corresponde à definida no módulo messaging
  event_source_arn = data.terraform_remote_state.messaging.outputs.event_queues_arns["charges_on_vehicle_reserved"]

  # ARN da função Lambda SQS
  function_name = aws_lambda_function.charges_api_sqs_handler.arn

  enabled = true
  # Ajuste o batch_size conforme a necessidade de processamento
  batch_size = 10
}

# Trigger SQS -> Lambda SQS (para fila de Timeout)

resource "aws_lambda_event_source_mapping" "charges_timeout_trigger" {
  # ARN da fila SQS de timeout
  event_source_arn = data.terraform_remote_state.messaging.outputs.charge_timeout_queue_arn

  # ARN da mesma função Lambda SQS
  function_name = aws_lambda_function.charges_api_sqs_handler.arn

  enabled = true
  # Pode usar batch size menor para timeouts, se preferir processar mais rápido
  batch_size = 5
}

