# terraform/lambda-sales/iam.tf
# --- Role e Policy para Lambda HTTP ---
resource "aws_iam_role" "sales_http_exec_role" {
  name = "${var.lambda_function_name_http}-${var.environment}-exec-role"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [{ Action = "sts:AssumeRole", Effect = "Allow", Principal = { Service = "lambda.amazonaws.com" } }]
  })
  tags = merge(
    var.project_tags, { Service = var.lambda_function_name_http }, # Tag de serviço específica
    { Name = "${var.lambda_function_name_http}-${var.environment}-exec-role" }
  )
}

resource "aws_iam_policy" "sales_http_policy" {
  name = "${var.lambda_function_name_http}-${var.environment}-policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      { # Permissão Secrets Manager para senha do DB
        Sid      = "AllowSecretManagerReadSalesDB",
        Effect   = "Allow",
        Action   = "secretsmanager:GetSecretValue",
        Resource = data.terraform_remote_state.rds_sales.outputs.sales_db_password_secret_arn
      },
      { # Permissão para publicar no Tópico SNS (necessário para POST /sales)
        Sid      = "AllowSnsPublishToMainBusHttp",
        Effect   = "Allow",
        Action   = "sns:Publish",
        Resource = data.terraform_remote_state.messaging.outputs.main_event_topic_arn
      }
      # Não precisa de permissões SQS aqui
    ]
  })
}

resource "aws_iam_role_policy_attachment" "sales_http_policy_attach" {
  role       = aws_iam_role.sales_http_exec_role.name
  policy_arn = aws_iam_policy.sales_http_policy.arn
}

resource "aws_iam_role_policy_attachment" "sales_http_logs_attach" {
  role       = aws_iam_role.sales_http_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# --- Role e Policy para Lambda SQS ---
resource "aws_iam_role" "sales_sqs_exec_role" {
  name = "${var.lambda_function_name_sqs}-${var.environment}-exec-role"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [{ Action = "sts:AssumeRole", Effect = "Allow", Principal = { Service = "lambda.amazonaws.com" } }]
  })
  tags = merge(
    var.project_tags, { Service = var.lambda_function_name_sqs }, # Tag de serviço específica
    { Name = "${var.lambda_function_name_sqs}-${var.environment}-exec-role" }
  )
}

resource "aws_iam_policy" "sales_sqs_policy" {
  name = "${var.lambda_function_name_sqs}-${var.environment}-policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      { # Permissão Secrets Manager para senha do DB (listener pode precisar)
        Sid      = "AllowSecretManagerReadSalesDBSQS",
        Effect   = "Allow",
        Action   = "secretsmanager:GetSecretValue",
        Resource = data.terraform_remote_state.rds_sales.outputs.sales_db_password_secret_arn
      },
      { # Permissões SQS para consumir da fila de eventos da Sales API
        Sid      = "AllowSqsConsumeSalesEvents",
        Effect   = "Allow",
        Action   = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes",
          "sqs:GetQueueUrl" # Necessário para resolver atributos
        ],
        # IMPORTANTE: Use a chave correta do mapa de ARNs exportado pelo módulo messaging
        Resource = data.terraform_remote_state.messaging.outputs.event_queues_arns["sales_on_events"]
      }
      # Não precisa de permissão SNS:Publish aqui (a menos que o listener precise publicar algo)
    ]
  })
}

resource "aws_iam_role_policy_attachment" "sales_sqs_policy_attach" {
  role       = aws_iam_role.sales_sqs_exec_role.name
  policy_arn = aws_iam_policy.sales_sqs_policy.arn
}

resource "aws_iam_role_policy_attachment" "sales_sqs_logs_attach" {
  role       = aws_iam_role.sales_sqs_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
