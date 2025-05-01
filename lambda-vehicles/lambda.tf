# terraform/lambda-vehicles/lambda.tf

# --- Definição da Lambda HTTP ---
resource "aws_cloudwatch_log_group" "vehicles_http_lambda_log_group" {
  name              = "/aws/lambda/${var.lambda_function_name_http}-${var.environment}"
  retention_in_days = 1
  tags              = merge(var.project_tags, { Name = "/aws/lambda/${var.lambda_function_name_http}-${var.environment}" })
}

resource "aws_lambda_function" "vehicles_api_http_handler" {
  function_name = "${var.lambda_function_name_http}-${var.environment}"
  role          = aws_iam_role.vehicles_http_exec_role.arn # Role HTTP
  package_type  = "Zip"

  # Código fonte (mesmo JAR)
  s3_bucket         = data.terraform_remote_state.s3_artifacts.outputs.lambda_deploy_bucket_id
  s3_key            = aws_s3_object.vehicles_lambda_jar_upload.key
  s3_object_version = aws_s3_object.vehicles_lambda_jar_upload.version_id

  # Handler HTTP
  handler       = var.lambda_handler_http
  runtime       = var.lambda_runtime
  memory_size   = var.lambda_memory_size_http
  timeout       = var.lambda_timeout_http
  architectures = ["arm64"]

  environment {
    variables = {
      SPRING_PROFILES_ACTIVE = "prod,http"
      DB_HOST                = data.terraform_remote_state.rds_vehicles.outputs.vehicles_db_instance_endpoint
      DB_PORT                = tostring(data.terraform_remote_state.rds_vehicles.outputs.vehicles_db_instance_port)
      DB_NAME                = data.terraform_remote_state.rds_vehicles.outputs.vehicles_db_instance_name
      DB_USER                = data.terraform_remote_state.rds_vehicles.outputs.vehicles_db_instance_username
      DB_PASSWORD_SECRET_ARN = data.terraform_remote_state.rds_vehicles.outputs.vehicles_db_password_secret_arn
      SPRING_SECURITY_OAUTH2_RESOURCESERVER_JWT_ISSUER_URI = data.terraform_remote_state.cognito.outputs.cognito_user_pool_issuer
      # SNS_TOPIC_MAIN_EVENT_BUS_ARN = data.terraform_remote_state.messaging.outputs.main_event_topic_arn # Não publica SNS diretamente
    }
  }
  publish = true

  depends_on = [
    aws_cloudwatch_log_group.vehicles_http_lambda_log_group,
    aws_iam_role_policy_attachment.vehicles_http_policy_attach,
    aws_iam_role_policy_attachment.vehicles_http_logs_attach,
    aws_s3_object.vehicles_lambda_jar_upload
  ]
  tags = merge(var.project_tags, { Name = "${var.lambda_function_name_http}-${var.environment}" })
}

# --- Definição da Lambda SQS (ÚNICA) ---
resource "aws_cloudwatch_log_group" "vehicles_sqs_lambda_log_group" {
  name              = "/aws/lambda/${var.lambda_function_name_sqs}-${var.environment}"
  retention_in_days = 1
  tags              = merge(var.project_tags, { Name = "/aws/lambda/${var.lambda_function_name_sqs}-${var.environment}" })
}

resource "aws_lambda_function" "vehicles_api_sqs_handler" {
  function_name = "${var.lambda_function_name_sqs}-${var.environment}"
  role          = aws_iam_role.vehicles_sqs_exec_role.arn # Role SQS
  package_type  = "Zip"

  # Código fonte (mesmo JAR)
  s3_bucket         = data.terraform_remote_state.s3_artifacts.outputs.lambda_deploy_bucket_id
  s3_key            = aws_s3_object.vehicles_lambda_jar_upload.key
  s3_object_version = aws_s3_object.vehicles_lambda_jar_upload.version_id

  # Handler SQS (FunctionInvoker)
  handler       = var.lambda_handler_sqs
  runtime       = var.lambda_runtime
  memory_size   = var.lambda_memory_size_sqs
  timeout       = var.lambda_timeout_sqs
  architectures = ["arm64"]

  environment {
    variables = {
      SPRING_PROFILES_ACTIVE = "prod,sqs"
      DB_HOST                = data.terraform_remote_state.rds_vehicles.outputs.vehicles_db_instance_endpoint
      DB_PORT                = tostring(data.terraform_remote_state.rds_vehicles.outputs.vehicles_db_instance_port)
      DB_NAME                = data.terraform_remote_state.rds_vehicles.outputs.vehicles_db_instance_name
      DB_USER                = data.terraform_remote_state.rds_vehicles.outputs.vehicles_db_instance_username
      DB_PASSWORD_SECRET_ARN = data.terraform_remote_state.rds_vehicles.outputs.vehicles_db_password_secret_arn
      # Nome da fila unificada (lido pelo application.yml)
      SQS_QUEUE_VEHICLES_EVENTS_NAME = data.terraform_remote_state.messaging.outputs.vehicles_events_queue_name # Usa o novo output
      # ARN do Tópico (para publicar VehicleReserved/Failed)
      SNS_TOPIC_MAIN_EVENT_BUS_ARN = data.terraform_remote_state.messaging.outputs.main_event_topic_arn
      # Nome do bean Consumer único
      SPRING_CLOUD_FUNCTION_DEFINITION = "vehicleEventsConsumer"
    }
  }
  publish = true
  
  depends_on = [
    aws_cloudwatch_log_group.vehicles_sqs_lambda_log_group,
    aws_iam_role_policy_attachment.vehicles_sqs_policy_attach,
    aws_iam_role_policy_attachment.vehicles_sqs_logs_attach,
    aws_s3_object.vehicles_lambda_jar_upload
  ]
  tags = merge(var.project_tags, { Name = "${var.lambda_function_name_sqs}-${var.environment}" })
}

