resource "aws_cloudwatch_log_group" "vehicles_lambda_log_group" {
  name              = "/aws/lambda/${var.lambda_function_name}-${var.environment}"
  retention_in_days = 1
  tags              = merge(var.project_tags, { Name = "/aws/lambda/${var.lambda_function_name}-${var.environment}" })
}

resource "aws_lambda_function" "vehicles_api_handler" {
  function_name = "${var.lambda_function_name}-${var.environment}"
  role          = aws_iam_role.vehicles_lambda_exec_role.arn # Role criada em iam.tf
  package_type  = "Zip"

  # Código fonte vindo do S3
  s3_bucket         = data.terraform_remote_state.s3_artifacts.outputs.lambda_deploy_bucket_id
  s3_key            = aws_s3_object.vehicles_lambda_jar_upload.key
  s3_object_version = aws_s3_object.vehicles_lambda_jar_upload.version_id

  # Configurações do Runtime Java
  handler       = var.lambda_handler
  runtime       = var.lambda_runtime
  memory_size   = var.lambda_memory_size
  timeout       = var.lambda_timeout
  architectures = ["arm64"]

  # Configuração de Rede para acessar RDS privado
  vpc_config {
    subnet_ids         = data.terraform_remote_state.rds_vehicles.outputs.db_subnet_group_subnet_ids
    security_group_ids = [aws_security_group.vehicles_lambda_sg.id]
  }

  environment {
    variables = {
      # Dados de conexão RDS lidos do remote state 'rds-vehicles'
      DB_HOST                = data.terraform_remote_state.rds_vehicles.outputs.vehicles_db_instance_endpoint
      DB_PORT                = tostring(data.terraform_remote_state.rds_vehicles.outputs.vehicles_db_instance_port)
      DB_NAME                = data.terraform_remote_state.rds_vehicles.outputs.vehicles_db_instance_name
      DB_USER                = data.terraform_remote_state.rds_vehicles.outputs.vehicles_db_instance_username
      DB_PASSWORD_SECRET_ARN = data.terraform_remote_state.rds_vehicles.outputs.vehicles_db_password_secret_arn
      # Issuer do Cognito (para Spring Security)
      SPRING_SECURITY_OAUTH2_RESOURCESERVER_JWT_ISSUER_URI = data.terraform_remote_state.cognito.outputs.cognito_user_pool_issuer
      # Perfil Spring
      SPRING_PROFILES_ACTIVE = var.environment

      # (Opcional) ARNs/URLs de SQS/SNS lidos do 'messaging' se necessário
      # EXAMPLE_QUEUE_URL = data.terraform_remote_state.messaging.outputs.some_queue_url
      # EVENT_TOPIC_ARN   = data.terraform_remote_state.messaging.outputs.main_event_topic_arn
    }
  }
  publish = true

  depends_on = [
    aws_cloudwatch_log_group.vehicles_lambda_log_group,
    aws_iam_role_policy_attachment.vehicles_lambda_policy_attach,
    aws_iam_role_policy_attachment.vehicles_lambda_logs_attach,
    aws_iam_role_policy_attachment.vehicles_lambda_vpc_attach
  ]
  tags = merge(
    var.project_tags,
    { Name = "${var.lambda_function_name}-${var.environment}" }
  )
}

# Permissão para API Gateway invocar esta Lambda
resource "aws_lambda_permission" "vehicles_api_gw_permission" {
  statement_id  = "AllowAPIGatewayInvokeVehiclesAPI"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.vehicles_api_handler.function_name
  principal     = "apigateway.amazonaws.com"
  # Source ARN usa o ARN de execução da API GW compartilhada (lido do remote state 'api_gateway')
  # O /*/* permite qualquer método e path vindo dessa API GW específica.
  # Restrinja mais se quiser (ex: "${...}/*/GET/vehicles/*")
  source_arn = "${data.terraform_remote_state.api_gateway.outputs.api_gateway_execution_arn}/*/*"
}