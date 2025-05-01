# terraform/lambda-vehicles/lambda.tf

resource "aws_cloudwatch_log_group" "vehicles_http_lambda_log_group" {
  name              = "/aws/lambda/${var.lambda_function_name_http}-${var.environment}" # Nome atualizado
  retention_in_days = 1
  tags              = merge(var.project_tags, { Name = "/aws/lambda/${var.lambda_function_name_http}-${var.environment}" })
}

resource "aws_lambda_function" "vehicles_api_http_handler" {
  function_name = "${var.lambda_function_name_http}-${var.environment}" # Nome atualizado
  role          = aws_iam_role.vehicles_http_exec_role.arn              # Role HTTP
  package_type  = "Zip"
  # Código fonte (mesmo JAR)
  s3_bucket         = data.terraform_remote_state.s3_artifacts.outputs.lambda_deploy_bucket_id
  s3_key            = aws_s3_object.vehicles_lambda_jar_upload.key
  s3_object_version = aws_s3_object.vehicles_lambda_jar_upload.version_id
  # Handler HTTP
  handler       = var.lambda_handler_http
  runtime       = var.lambda_runtime
  memory_size   = var.lambda_memory_size_http # Memória HTTP
  timeout       = var.lambda_timeout_http     # Timeout HTTP
  architectures = ["arm64"]

  snap_start {
    apply_on = "PublishedVersions"
  }

  environment {
    variables = {
      DB_HOST                                              = data.terraform_remote_state.rds_vehicles.outputs.vehicles_db_instance_endpoint
      DB_PORT                                              = tostring(data.terraform_remote_state.rds_vehicles.outputs.vehicles_db_instance_port)
      DB_NAME                                              = data.terraform_remote_state.rds_vehicles.outputs.vehicles_db_instance_name
      DB_USER                                              = data.terraform_remote_state.rds_vehicles.outputs.vehicles_db_instance_username
      DB_PASSWORD_SECRET_ARN                               = data.terraform_remote_state.rds_vehicles.outputs.vehicles_db_password_secret_arn
      SPRING_SECURITY_OAUTH2_RESOURCESERVER_JWT_ISSUER_URI = data.terraform_remote_state.cognito.outputs.cognito_user_pool_issuer
      # Perfil Spring para HTTP
      SPRING_PROFILES_ACTIVE       = "prod,http" # Ativa perfil 'prod' e 'http'
      SNS_TOPIC_MAIN_EVENT_BUS_ARN = data.terraform_remote_state.messaging.outputs.main_event_topic_arn
    }
  }
  publish = true
  depends_on = [
    aws_cloudwatch_log_group.vehicles_http_lambda_log_group,
    aws_iam_role_policy_attachment.vehicles_http_policy_attach,
    aws_iam_role_policy_attachment.vehicles_http_logs_attach,
  ]
  tags = merge(var.project_tags, { Name = "${var.lambda_function_name_http}-${var.environment}" })
}

# --- Definição da Lambda SQS ---
resource "aws_cloudwatch_log_group" "vehicles_sqs_lambda_log_group" {
  name              = "/aws/lambda/${var.lambda_function_name_sqs}-${var.environment}" # Nome novo
  retention_in_days = 1
  tags              = merge(var.project_tags, { Name = "/aws/lambda/${var.lambda_function_name_sqs}-${var.environment}" })
}

resource "aws_lambda_function" "vehicles_api_sqs_handler" {
  function_name = "${var.lambda_function_name_sqs}-${var.environment}" # Nome novo
  role          = aws_iam_role.vehicles_sqs_exec_role.arn              # Role SQS
  package_type  = "Zip"
  # Código fonte (mesmo JAR)
  s3_bucket         = data.terraform_remote_state.s3_artifacts.outputs.lambda_deploy_bucket_id
  s3_key            = aws_s3_object.vehicles_lambda_jar_upload.key
  s3_object_version = aws_s3_object.vehicles_lambda_jar_upload.version_id
  # Handler SQS
  handler       = var.lambda_handler_sqs
  runtime       = var.lambda_runtime
  memory_size   = var.lambda_memory_size_sqs # Memória SQS
  timeout       = var.lambda_timeout_sqs     # Timeout SQS
  architectures = ["arm64"]

  snap_start {
    apply_on = "PublishedVersions"
  }

  environment {
    variables = {
      DB_HOST                = data.terraform_remote_state.rds_vehicles.outputs.vehicles_db_instance_endpoint
      DB_PORT                = tostring(data.terraform_remote_state.rds_vehicles.outputs.vehicles_db_instance_port)
      DB_NAME                = data.terraform_remote_state.rds_vehicles.outputs.vehicles_db_instance_name
      DB_USER                = data.terraform_remote_state.rds_vehicles.outputs.vehicles_db_instance_username
      DB_PASSWORD_SECRET_ARN = data.terraform_remote_state.rds_vehicles.outputs.vehicles_db_password_secret_arn
      # Issuer NÃO é necessário aqui (a menos que valide algo internamente)
      # SPRING_SECURITY_OAUTH2_RESOURCESERVER_JWT_ISSUER_URI = data.terraform_remote_state.cognito.outputs.cognito_user_pool_issuer
      # Perfil Spring para SQS
      SPRING_PROFILES_ACTIVE = "prod,sqs" # Ativa perfil 'prod' e 'sqs'
      # Variáveis SQS/SNS SÃO necessárias aqui
      SQS_QUEUE_VEHICLES_SALE_CREATED_NAME = data.terraform_remote_state.messaging.outputs.vehicles_sale_created_queue_name
      SNS_TOPIC_MAIN_EVENT_BUS_ARN         = data.terraform_remote_state.messaging.outputs.main_event_topic_arn
    }
  }
  publish = true
  depends_on = [
    aws_cloudwatch_log_group.vehicles_sqs_lambda_log_group,
    aws_iam_role_policy_attachment.vehicles_sqs_policy_attach,
    aws_iam_role_policy_attachment.vehicles_sqs_logs_attach,
  ]
  tags = merge(var.project_tags, { Name = "${var.lambda_function_name_sqs}-${var.environment}" })
}