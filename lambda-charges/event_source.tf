resource "aws_lambda_event_source_mapping" "charges_vehicle_reserved_trigger" {
  # ARN da fila SQS de eventos da Charges API (VehicleReserved)
  event_source_arn = data.terraform_remote_state.messaging.outputs.event_queues_arns["charges_on_vehicle_reserved"]

  function_name = aws_lambda_alias.charges_sqs_alias_live.arn

  enabled    = true
  batch_size = 10
}

# Trigger SQS -> Lambda SQS (para fila de Timeout)

resource "aws_lambda_event_source_mapping" "charges_timeout_trigger" {
  event_source_arn = data.terraform_remote_state.messaging.outputs.charge_timeout_queue_arn

  function_name = aws_lambda_alias.charges_sqs_alias_live.arn

  enabled    = true
  batch_size = 5
}