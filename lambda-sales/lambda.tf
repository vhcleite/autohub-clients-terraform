# terraform/lambda-sales/lambda.tf

# --- Definição da Lambda HTTP ---
resource "aws_cloudwatch_log_group" "sales_http_lambda_log_group" {
  name              = "/aws/lambda/${var.lambda_function_name_http}-${var.environment}"
  retention_in_days = 1
  tags              = merge(var.project_tags, { Name = "/aws/lambda/${var.lambda_function_name_http}-${var.environment}" })
}

resource "aws_lambda_function" "sales_api_http_handler" {
  function_name = "${var.lambda_function_name_http}-${var.environment}"
  role          = aws_iam_role.sales_http_exec_role.arn # Role HTTP
  package_type  = "Zip"

  # Código fonte (mesmo JAR para ambas)
  s3_bucket         = data.terraform_remote_state.s3_artifacts.outputs.lambda_deploy_bucket_id
  s3_key            = aws_s3_object.sales_lambda_jar_upload.key
  s3_object_version = aws_s3_object.sales_lambda_jar_upload.version_id

  # Handler HTTP
  handler       = var.lambda_handler_http
  runtime       = var.lambda_runtime
  memory_size   = var.lambda_memory_size_http
  timeout       = var.lambda_timeout_http
  architectures = ["arm64"]

  # REMOVIDO: vpc_config - Lambda roda fora da VPC

  environment {
    variables = {
      # --- Configurações Comuns ---
      SPRING_PROFILES_ACTIVE = "prod,http" # Ativa perfis prod e http
      # --- Configurações DB ---
      DB_HOST                = data.terraform_remote_state.rds_sales.outputs.sales_db_instance_endpoint
      DB_PORT                = tostring(data.terraform_remote_state.rds_sales.outputs.sales_db_instance_port)
      DB_NAME                = data.terraform_remote_state.rds_sales.outputs.sales_db_instance_name
      DB_USER                = data.terraform_remote_state.rds_sales.outputs.sales_db_instance_username
      DB_PASSWORD_SECRET_ARN = data.terraform_remote_state.rds_sales.outputs.sales_db_password_secret_arn
      # --- Configurações Segurança/Cognito ---
      SPRING_SECURITY_OAUTH2_RESOURCESERVER_JWT_ISSUER_URI = data.terraform_remote_state.cognito.outputs.cognito_user_pool_issuer
      # --- Configurações Mensageria (Necessário para criar o Publisher) ---
      SNS_TOPIC_MAIN_EVENT_BUS_ARN = data.terraform_remote_state.messaging.outputs.main_event_topic_arn
      # SQS_QUEUE_SALES_EVENTS_NAME = data.terraform_remote_state.messaging.outputs.event_queues_arns["sales_on_events"] # Não estritamente necessário aqui
    }
  }
  publish = true
  snap_start {
    apply_on = "PublishedVersions" 
  }
  depends_on = [
    aws_cloudwatch_log_group.sales_http_lambda_log_group,
    aws_iam_role_policy_attachment.sales_http_policy_attach,
    aws_iam_role_policy_attachment.sales_http_logs_attach,
    aws_s3_object.sales_lambda_jar_upload # Depende do upload do JAR
  ]
  tags = merge(var.project_tags, { Name = "${var.lambda_function_name_http}-${var.environment}" })
}

# --- Definição da Lambda SQS ---
resource "aws_cloudwatch_log_group" "sales_sqs_lambda_log_group" {
  name              = "/aws/lambda/${var.lambda_function_name_sqs}-${var.environment}"
  retention_in_days = 1 # Ajuste conforme necessidade
  tags              = merge(var.project_tags, { Name = "/aws/lambda/${var.lambda_function_name_sqs}-${var.environment}" })
}

resource "aws_lambda_function" "sales_api_sqs_handler" {
  function_name = "${var.lambda_function_name_sqs}-${var.environment}"
  role          = aws_iam_role.sales_sqs_exec_role.arn # Role SQS
  package_type  = "Zip"

  # Código fonte (mesmo JAR para ambas)
  s3_bucket         = data.terraform_remote_state.s3_artifacts.outputs.lambda_deploy_bucket_id
  s3_key            = aws_s3_object.sales_lambda_jar_upload.key
  s3_object_version = aws_s3_object.sales_lambda_jar_upload.version_id

  # Handler SQS (FunctionInvoker)
  handler       = var.lambda_handler_sqs
  runtime       = var.lambda_runtime
  memory_size   = var.lambda_memory_size_sqs
  timeout       = var.lambda_timeout_sqs
  architectures = ["arm64"]

  # REMOVIDO: vpc_config - Lambda roda fora da VPC

  environment {
    variables = {
      # --- Configurações Comuns ---
      SPRING_PROFILES_ACTIVE = "prod,sqs" # Ativa perfis prod e sqs
      # --- Configurações DB ---
      DB_HOST                = data.terraform_remote_state.rds_sales.outputs.sales_db_instance_endpoint
      DB_PORT                = tostring(data.terraform_remote_state.rds_sales.outputs.sales_db_instance_port)
      DB_NAME                = data.terraform_remote_state.rds_sales.outputs.sales_db_instance_name
      DB_USER                = data.terraform_remote_state.rds_sales.outputs.sales_db_instance_username
      DB_PASSWORD_SECRET_ARN = data.terraform_remote_state.rds_sales.outputs.sales_db_password_secret_arn
      # --- Configurações Mensageria ---
      # Nome da fila que o @Bean Consumer precisa (ou leia do application.yml)
      SQS_QUEUE_SALES_EVENTS_NAME = element(split(":", data.terraform_remote_state.messaging.outputs.event_queues_arns["sales_on_events"]), 5)
      # ARN do Tópico (se o listener precisar publicar algo)
      SNS_TOPIC_MAIN_EVENT_BUS_ARN = data.terraform_remote_state.messaging.outputs.main_event_topic_arn
      # --- Configuração Spring Cloud Function ---
      # Diz ao FunctionInvoker qual @Bean Consumer<SQSEvent> usar
      SPRING_CLOUD_FUNCTION_DEFINITION = "saleCreatedConsumer"
    }
  }
  publish = true
  snap_start {
    apply_on = "PublishedVersions" 
  }
  depends_on = [
    aws_cloudwatch_log_group.sales_sqs_lambda_log_group,
    aws_iam_role_policy_attachment.sales_sqs_policy_attach,
    aws_iam_role_policy_attachment.sales_sqs_logs_attach,
    aws_s3_object.sales_lambda_jar_upload # Depende do upload do JAR
  ]
  tags = merge(var.project_tags, { Name = "${var.lambda_function_name_sqs}-${var.environment}" })
}

