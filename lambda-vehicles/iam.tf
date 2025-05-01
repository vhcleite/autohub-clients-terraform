# terraform/lambda-vehicles/iam.tf

# --- Role e Policy para Lambda HTTP ---
resource "aws_iam_role" "vehicles_http_exec_role" {
  name = "${var.lambda_function_name_http}-${var.environment}-exec-role"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [{ Action = "sts:AssumeRole", Effect = "Allow", Principal = { Service = "lambda.amazonaws.com" } }]
  })
  tags = merge(
    var.project_tags, { Service = var.lambda_function_name_http },
    { Name = "${var.lambda_function_name_http}-${var.environment}-exec-role" }
  )
}

resource "aws_iam_policy" "vehicles_http_policy" {
  name = "${var.lambda_function_name_http}-${var.environment}-policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      { # Permissão Secrets Manager para senha do DB
        Sid      = "AllowSecretManagerReadVehiclesDB",
        Effect   = "Allow",
        Action   = "secretsmanager:GetSecretValue",
        Resource = data.terraform_remote_state.rds_vehicles.outputs.vehicles_db_password_secret_arn
      }
      # Permissão para publicar SNS não é necessária para a Lambda HTTP de Veículos
    ]
  })
}

resource "aws_iam_role_policy_attachment" "vehicles_http_policy_attach" {
  role       = aws_iam_role.vehicles_http_exec_role.name
  policy_arn = aws_iam_policy.vehicles_http_policy.arn
}

resource "aws_iam_role_policy_attachment" "vehicles_http_logs_attach" {
  role       = aws_iam_role.vehicles_http_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# --- Role e Policy para Lambda SQS (ÚNICA) ---
resource "aws_iam_role" "vehicles_sqs_exec_role" {
  name = "${var.lambda_function_name_sqs}-${var.environment}-exec-role"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [{ Action = "sts:AssumeRole", Effect = "Allow", Principal = { Service = "lambda.amazonaws.com" } }]
  })
  tags = merge(
    var.project_tags, { Service = var.lambda_function_name_sqs },
    { Name = "${var.lambda_function_name_sqs}-${var.environment}-exec-role" }
  )
}

resource "aws_iam_policy" "vehicles_sqs_policy" {
  name = "${var.lambda_function_name_sqs}-${var.environment}-policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      { # Permissão Secrets Manager para senha do DB
        Sid      = "AllowSecretManagerReadVehiclesDBSQS",
        Effect   = "Allow",
        Action   = "secretsmanager:GetSecretValue",
        Resource = data.terraform_remote_state.rds_vehicles.outputs.vehicles_db_password_secret_arn
      },
      { # Permissão para publicar no Tópico SNS (VehicleReserved/Failed)
        Sid      = "AllowSnsPublishToMainBusSQS",
        Effect   = "Allow",
        Action   = "sns:Publish",
        Resource = data.terraform_remote_state.messaging.outputs.main_event_topic_arn
      },
      { # Permissões SQS para consumir da fila unificada de eventos da Vehicles API
        Sid      = "AllowSqsConsumeVehiclesEvents",
        Effect   = "Allow",
        Action   = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes",
          "sqs:GetQueueUrl"
        ],
        # Aponta para o ARN da fila unificada
        Resource = data.terraform_remote_state.messaging.outputs.event_queues_arns["vehicles_events"]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "vehicles_sqs_policy_attach" {
  role       = aws_iam_role.vehicles_sqs_exec_role.name
  policy_arn = aws_iam_policy.vehicles_sqs_policy.arn
}

resource "aws_iam_role_policy_attachment" "vehicles_sqs_logs_attach" {
  role       = aws_iam_role.vehicles_sqs_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

