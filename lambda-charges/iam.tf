# --- Role e Policy para Lambda HTTP (Charges API) ---
resource "aws_iam_role" "charges_http_exec_role" {
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

resource "aws_iam_policy" "charges_http_policy" {
  name = "${var.lambda_function_name_http}-${var.environment}-policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      { # Permissão para ler/escrever na tabela DynamoDB de Cobranças
        Sid    = "AllowDynamoDBChargesAccess",
        Effect = "Allow",
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:Query"
        ],
        Resource = [
          data.terraform_remote_state.dynamodb_charges.outputs.charges_table_arn,
          data.terraform_remote_state.dynamodb_charges.outputs.gsi_sale_id_arn
        ]
      },
      { # Permissão para publicar no Tópico SNS (necessário para PaymentCompleted/Failed)
        Sid      = "AllowSnsPublishToMainBusHttp",
        Effect   = "Allow",
        Action   = "sns:Publish",
        Resource = data.terraform_remote_state.messaging.outputs.main_event_topic_arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "charges_http_policy_attach" {
  role       = aws_iam_role.charges_http_exec_role.name
  policy_arn = aws_iam_policy.charges_http_policy.arn
}

resource "aws_iam_role_policy_attachment" "charges_http_logs_attach" {
  role       = aws_iam_role.charges_http_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# --- Role e Policy para Lambda SQS (Charges API) ---
resource "aws_iam_role" "charges_sqs_exec_role" {
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

resource "aws_iam_policy" "charges_sqs_policy" {
  name = "${var.lambda_function_name_sqs}-${var.environment}-policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      { # Permissão para ler/escrever na tabela DynamoDB de Cobranças
        Sid    = "AllowDynamoDBChargesAccessSQS",
        Effect = "Allow",
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:Query"
        ],
        Resource = [
          data.terraform_remote_state.dynamodb_charges.outputs.charges_table_arn,
          data.terraform_remote_state.dynamodb_charges.outputs.gsi_sale_id_arn
        ]
      },
      { # Permissão para publicar no Tópico SNS (ChargeCreated/Failed, ChargeExpired)
        Sid      = "AllowSnsPublishToMainBusSQS",
        Effect   = "Allow",
        Action   = "sns:Publish",
        Resource = data.terraform_remote_state.messaging.outputs.main_event_topic_arn
      },
      { # Permissões SQS para consumir da fila VehicleReserved
        Sid    = "AllowSqsConsumeVehicleReserved",
        Effect = "Allow",
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ],
        Resource = data.terraform_remote_state.messaging.outputs.event_queues_arns["charges_on_vehicle_reserved"]
      },
      { # Permissões SQS para consumir da fila de Timeout
        Sid    = "AllowSqsConsumeChargeTimeout",
        Effect = "Allow",
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ],
        Resource = data.terraform_remote_state.messaging.outputs.charge_timeout_queue_arn
      },
      { # Permissão para ENVIAR mensagem para a fila de Timeout (agendamento)
        Sid      = "AllowSqsSendChargeTimeout",
        Effect   = "Allow",
        Action   = "sqs:SendMessage",
        Resource = data.terraform_remote_state.messaging.outputs.charge_timeout_queue_arn
      }
      # Futuramente: Permissão para SES (ex: "ses:SendEmail")
    ]
  })
}

resource "aws_iam_role_policy_attachment" "charges_sqs_policy_attach" {
  role       = aws_iam_role.charges_sqs_exec_role.name
  policy_arn = aws_iam_policy.charges_sqs_policy.arn
}

resource "aws_iam_role_policy_attachment" "charges_sqs_logs_attach" {
  role       = aws_iam_role.charges_sqs_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
