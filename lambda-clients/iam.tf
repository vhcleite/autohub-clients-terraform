resource "aws_iam_role" "clients_lambda_exec_role" {
  name = "${var.lambda_function_name}-${var.environment}-exec-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole" # A ação de assumir a role
      Effect = "Allow"          # Permitir
      Principal = {
        Service = "lambda.amazonaws.com" # O serviço que pode assumir
      }
    }]
  })
  tags = merge(
    var.project_tags,
    {
      Name        = "${var.lambda_function_name}-${var.environment}-exec-role"
      Environment = var.environment
    }
  )
}

resource "aws_iam_policy" "clients_lambda_policy" {
  name = "${var.lambda_function_name}-${var.environment}-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      { # Permissões DynamoDB para a tabela de clientes
        Sid    = "AllowDynamoDBClientsAccess"
        Effect = "Allow"
        Action = [
          "dynamodb:PutItem",
          "dynamodb:GetItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:Query" # Para o índice de email
        ]
        Resource = [
          data.terraform_remote_state.database_clients.outputs.dynamodb_user_table_arn,
          "${data.terraform_remote_state.database_clients.outputs.dynamodb_user_table_arn}/index/${data.terraform_remote_state.database_clients.outputs.dynamodb_user_table_email_index_name}"
        ]
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "clients_lambda_policy_attach" {
  role       = aws_iam_role.clients_lambda_exec_role.name
  policy_arn = aws_iam_policy.clients_lambda_policy.arn
}
resource "aws_iam_role_policy_attachment" "clients_lambda_logs_attach" {
  role       = aws_iam_role.clients_lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}