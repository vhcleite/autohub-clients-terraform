# terraform/lambda-sales/iam.tf


# Security Group para a Lambda de Vendas (permite saída para RDS e AWS Services)
resource "aws_security_group" "sales_lambda_sg" {
  name        = "sales_lambda_sg"
  description = "Allow lambda egress for Sales API"
  vpc_id      = var.vpc_id

  # Permite toda saída - pode restringir mais se necessário
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = merge(
    var.project_tags,
    {
      Name = "sales_lambda_sg"
    }
  )
}


# Role IAM para a Lambda de Vendas
resource "aws_iam_role" "sales_lambda_exec_role" {
  name = "${var.lambda_function_name}-${var.environment}-exec-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
  tags = merge(
    var.project_tags,
    {
      Name        = "${var.lambda_function_name}-${var.environment}-exec-role"
      Environment = var.environment
    }
  )
}

# Política IAM Customizada
resource "aws_iam_policy" "sales_lambda_policy" {
  name = "${var.lambda_function_name}-${var.environment}-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      { # Permissão para ler a senha do DB do Secrets Manager
        Sid      = "AllowSecretManagerRead"
        Effect   = "Allow"
        Action   = "secretsmanager:GetSecretValue"
        Resource = data.terraform_remote_state.rds_sales.outputs.sales_db_password_secret_arn # ARN do Secret
      },
      # { # Permissão para publicar no SNS/EventBridge
      #   Sid      = "AllowEventPublish"
      #   Effect   = "Allow"
      #   Action   = ["events:PutEvents", "sns:Publish"]
      #   Resource = [data.terraform_remote_state.messaging.outputs.event_bus_arn] # ARN do Barramento/Tópico
      # },
      { # Permissões de Rede para VPC Lambda (se rodar em VPC)
        Sid    = "AllowVPCAccess",
        Effect = "Allow",
        Action = [
          "ec2:CreateNetworkInterface",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DeleteNetworkInterface"
        ],
        Resource = "*" # Necessário para criar ENIs na VPC
      }
    ]
  })
}

# Anexar Policies à Role
resource "aws_iam_role_policy_attachment" "sales_lambda_policy_attach" {
  role       = aws_iam_role.sales_lambda_exec_role.name
  policy_arn = aws_iam_policy.sales_lambda_policy.arn
}
resource "aws_iam_role_policy_attachment" "sales_lambda_logs_attach" {
  role       = aws_iam_role.sales_lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
# Anexar política para acesso à VPC (se rodar em VPC)
resource "aws_iam_role_policy_attachment" "sales_lambda_vpc_attach" {
  role       = aws_iam_role.sales_lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}