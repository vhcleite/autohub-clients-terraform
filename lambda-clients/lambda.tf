# Log Group (opcional, mas bom)
resource "aws_cloudwatch_log_group" "clients_lambda_log_group" {
  name              = "/aws/lambda/${var.lambda_function_name}-${var.environment}"
  retention_in_days = 1
  tags = merge(
    var.project_tags,
    {
      Name        = "/aws/lambda/${var.lambda_function_name}-${var.environment}"
      Environment = var.environment
    }
  )
}

resource "aws_lambda_function" "clients_api_handler" {
  function_name = "${var.lambda_function_name}-${var.environment}"
  role          = aws_iam_role.clients_lambda_exec_role.arn # Role específica

  s3_bucket         = data.terraform_remote_state.s3_artifacts.outputs.lambda_deploy_bucket_id # Bucket de deploy
  s3_key            = aws_s3_object.clients_lambda_jar_upload.key                              # Key do JAR desta API
  s3_object_version = aws_s3_object.clients_lambda_jar_upload.version_id                       # Trigger pela versão

  handler = var.lambda_handler # Handler Java (StreamLambdaHandler)
  runtime = var.lambda_runtime # java17

  memory_size = var.lambda_memory_size
  timeout     = var.lambda_timeout

  environment {
    variables = {
      DYNAMODB_TABLE_NAME                                  = data.terraform_remote_state.database_clients.outputs.dynamodb_user_table_name
      SPRING_SECURITY_OAUTH2_RESOURCESERVER_JWT_ISSUER_URI = data.terraform_remote_state.cognito.outputs.cognito_user_pool_issuer
      SPRING_PROFILES_ACTIVE                               = "prod"
    }
  }
  publish    = true
  depends_on = [aws_cloudwatch_log_group.clients_lambda_log_group]
}

# Permissão para o API Gateway compartilhado invocar esta Lambda específica
resource "aws_lambda_permission" "clients_api_gw_permission" {
  statement_id  = "AllowAPIGatewayInvokeClientsAPI"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.clients_api_handler.function_name
  principal     = "apigateway.amazonaws.com"
  # Source ARN usa o ARN de execução do API Gateway lido do remote state
  # Pode restringir ao path /users/* se quiser mais segurança
  source_arn = "${data.terraform_remote_state.api_gateway.outputs.api_gateway_execution_arn}/*/*"
}