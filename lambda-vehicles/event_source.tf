# Trigger SQS -> Lambda SQS (ÚNICO)

resource "aws_lambda_event_source_mapping" "vehicles_events_trigger" {
  # ARN da fila SQS unificada de eventos da Vehicles API
  event_source_arn = data.terraform_remote_state.messaging.outputs.event_queues_arns["vehicles_events"]
  function_name    = aws_lambda_alias.vehicles_sqs_alias_live.arn
  enabled          = true
  batch_size       = 1
}