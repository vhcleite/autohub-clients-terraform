# terraform/lambda-sales/event_source.tf

# Trigger SQS -> Lambda SQS
resource "aws_lambda_event_source_mapping" "sales_sqs_trigger" {
  # ARN da fila SQS de eventos da Sales API
  # Certifique-se que a chave "sales_on_events" corresponde à definida no módulo messaging
  event_source_arn = data.terraform_remote_state.messaging.outputs.event_queues_arns["sales_on_events"]

  # ARN da função Lambda SQS
  function_name    = aws_lambda_alias.sales_sqs_alias_live.arn

  enabled          = true
  # Ajuste o batch_size conforme a necessidade de processamento
  batch_size       = 1
}

