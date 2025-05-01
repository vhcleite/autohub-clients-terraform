# Em lambda-vehicles/event_source.tf

# Trigger SQS -> Lambda SQS
resource "aws_lambda_event_source_mapping" "vehicles_sqs_trigger" {
  event_source_arn = data.terraform_remote_state.messaging.outputs.event_queues_arns["vehicles_on_sale_created"]
  # Aponta para a Lambda SQS
  function_name                      = aws_lambda_function.vehicles_api_sqs_handler.arn
  enabled                            = true
  batch_size                         = 1 # Ajuste conforme necessidade
  maximum_batching_window_in_seconds = 0
}