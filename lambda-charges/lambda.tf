# --- Definição da Lambda HTTP ---
resource "aws_cloudwatch_log_group" "charges_http_lambda_log_group" {
  name              = "/aws/lambda/${var.lambda_function_name_http}-${var.environment}"
  retention_in_days = 1 # Ajuste conforme necessidade
  tags              = merge(var.project_tags, { Name = "/aws/lambda/${var.lambda_function_name_http}-${var.environment}" })
}

resource "aws_lambda_function" "charges_api_http_handler" {
  function_name = "${var.lambda_function_name_http}-${var.environment}"
  role          = aws_iam_role.charges_http_exec_role.arn # Role HTTP
  package_type  = "Zip"

  # Código fonte (mesmo JAR para ambas)
  s3_bucket         = data.terraform_remote_state.s3_artifacts.outputs.lambda_deploy_bucket_id
  s3_key            = aws_s3_object.charges_lambda_jar_upload.key # Referência ao objeto S3 criado em s3.tf
  s3_object_version = aws_s3_object.charges_lambda_jar_upload.version_id

  # Handler HTTP
  handler       = var.lambda_handler_http
  runtime       = var.lambda_runtime
  memory_size   = var.lambda_memory_size_http
  timeout       = var.lambda_timeout_http
  architectures = ["arm64"]

  environment {
    variables = {
      # --- Configurações Comuns ---
      SPRING_PROFILES_ACTIVE = "prod,http"    # Ativa perfis prod e http
      # --- Configurações DynamoDB ---
      DYNAMODB_TABLE_CHARGES = data.terraform_remote_state.dynamodb_charges.outputs.charges_table_name
      # --- Configurações Segurança/Cognito (Se o GET /charges/sale/{id} for protegido) ---
      SPRING_SECURITY_OAUTH2_RESOURCESERVER_JWT_ISSUER_URI = data.terraform_remote_state.cognito.outputs.cognito_user_pool_issuer
      # --- Configurações Mensageria (Necessário para publicar PaymentCompleted/Failed) ---
      SNS_TOPIC_MAIN_EVENT_BUS_ARN = data.terraform_remote_state.messaging.outputs.main_event_topic_arn
      # --- URL da fila de timeout de pagamento ---
      SQS_QUEUE_CHARGE_TIMEOUT_URL = data.terraform_remote_state.messaging.outputs.charge_timeout_queue_url
    }
  }
  publish = true
  # Habilitar SnapStart para a Lambda HTTP se fizer sentido (para callbacks rápidos)
#   snap_start {
#     apply_on = "PublishedVersions"
#   }
  depends_on = [
    aws_cloudwatch_log_group.charges_http_lambda_log_group,
    aws_iam_role_policy_attachment.charges_http_policy_attach,
    aws_iam_role_policy_attachment.charges_http_logs_attach,
    aws_s3_object.charges_lambda_jar_upload
  ]
  tags = merge(var.project_tags, { Name = "${var.lambda_function_name_http}-${var.environment}" })
}

# --- Definição da Lambda SQS ---
resource "aws_cloudwatch_log_group" "charges_sqs_lambda_log_group" {
  name              = "/aws/lambda/${var.lambda_function_name_sqs}-${var.environment}"
  retention_in_days = 7 # Ajuste conforme necessidade
  tags              = merge(var.project_tags, { Name = "/aws/lambda/${var.lambda_function_name_sqs}-${var.environment}" })
}

resource "aws_lambda_function" "charges_api_sqs_handler" {
  function_name = "${var.lambda_function_name_sqs}-${var.environment}"
  role          = aws_iam_role.charges_sqs_exec_role.arn # Role SQS
  package_type  = "Zip"

  # Código fonte (mesmo JAR)
  s3_bucket         = data.terraform_remote_state.s3_artifacts.outputs.lambda_deploy_bucket_id
  s3_key            = aws_s3_object.charges_lambda_jar_upload.key
  s3_object_version = aws_s3_object.charges_lambda_jar_upload.version_id

  # Handler SQS (FunctionInvoker)
  handler       = var.lambda_handler_sqs
  runtime       = var.lambda_runtime
  memory_size   = var.lambda_memory_size_sqs
  timeout       = var.lambda_timeout_sqs
  architectures = ["arm64"]

  environment {
    variables = {
      # --- Configurações Comuns ---
      SPRING_PROFILES_ACTIVE = "prod,sqs"     # Ativa perfis prod e sqs
      # --- Configurações DynamoDB ---
      DYNAMODB_TABLE_CHARGES = data.terraform_remote_state.dynamodb_charges.outputs.charges_table_name
      # --- Configurações Mensageria ---
      # Nome da fila consumida (VehicleReserved) - O listener pode ler do application.yml que lê a Env Var
      # SQS_QUEUE_CHARGES_VEHICLE_RESERVED_NAME = element(split(":", data.terraform_remote_state.messaging.outputs.event_queues_arns["charges_on_vehicle_reserved"]), 5)
      # URL da fila de timeout (para enviar mensagens com delay)
      SQS_QUEUE_CHARGE_TIMEOUT_URL = data.terraform_remote_state.messaging.outputs.charge_timeout_queue_url
      # ARN do Tópico (para publicar ChargeCreated/Failed, ChargeExpired)
      SNS_TOPIC_MAIN_EVENT_BUS_ARN = data.terraform_remote_state.messaging.outputs.main_event_topic_arn
      # --- Configuração Spring Cloud Function ---
      # Diz ao FunctionInvoker qual @Bean Consumer<SQSEvent> usar
      SPRING_CLOUD_FUNCTION_DEFINITION = "chargeEventsConsumer" # Nome do bean na sua Application class
    }
  }
  publish = true
  # Habilitar SnapStart para a Lambda SQS é altamente recomendado
#   snap_start {
#     apply_on = "PublishedVersions"
#   }
  depends_on = [
    aws_cloudwatch_log_group.charges_sqs_lambda_log_group,
    aws_iam_role_policy_attachment.charges_sqs_policy_attach,
    aws_iam_role_policy_attachment.charges_sqs_logs_attach,
    aws_s3_object.charges_lambda_jar_upload
  ]
  tags = merge(var.project_tags, { Name = "${var.lambda_function_name_sqs}-${var.environment}" })
}
