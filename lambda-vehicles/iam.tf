# Security Group para a Lambda de Veículos
resource "aws_security_group" "vehicles_lambda_sg" {
  name        = "${var.lambda_function_name}-${var.environment}-sg"
  description = "Allow lambda egress for Vehicles API"
  vpc_id      = var.vpc_id # ID da VPC passado como variável

  # Regra de Saída: Permite conectar ao RDS na porta 5432
  egress {
    description = "Allow outbound Postgres to Vehicles DB SG"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    # ID do SG do RDS de Veículos, lido do remote state
    security_groups = [data.terraform_remote_state.rds_vehicles.outputs.vehicles_db_security_group_id]
  }

  # Regra de saída genérica para permitir outras conexões (ex: AWS APIs via VPC Endpoint)
  egress {
    from_port   = 443 # HTTPS para APIs AWS
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Ou restrinja a Prefix Lists de VPC Endpoints
  }

  tags = merge(
    var.project_tags,
    { Name = "${var.lambda_function_name}-${var.environment}-sg" }
  )
}

# Role IAM para a Lambda de Veículos
resource "aws_iam_role" "vehicles_lambda_exec_role" {
  name = "${var.lambda_function_name}-${var.environment}-exec-role"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [{ Action = "sts:AssumeRole", Effect = "Allow", Principal = { Service = "lambda.amazonaws.com" } }]
  })
  tags = merge(
    var.project_tags,
    { Name = "${var.lambda_function_name}-${var.environment}-exec-role" }
  )
}

# Política IAM Customizada
resource "aws_iam_policy" "vehicles_lambda_policy" {
  name = "${var.lambda_function_name}-${var.environment}-policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      { # Permissão para ler a senha do DB do Secrets Manager
        Sid      = "AllowSecretManagerReadVehiclesDB",
        Effect   = "Allow",
        Action   = "secretsmanager:GetSecretValue",
        Resource = data.terraform_remote_state.rds_vehicles.outputs.vehicles_db_password_secret_arn # ARN do Secret do DB Veículos
      },
      { # Permissão para publicar/enviar mensagens (exemplo para SNS)
        Sid      = "AllowSnsPublish"
        Effect   = "Allow"
        Action   = "sns:Publish"
        Resource = "*"
      },
      # Adicione permissões para SQS se este lambda for consumir ou enviar para SQS
    ]
  })
}

# Anexar Policies à Role
resource "aws_iam_role_policy_attachment" "vehicles_lambda_policy_attach" {
  role       = aws_iam_role.vehicles_lambda_exec_role.name
  policy_arn = aws_iam_policy.vehicles_lambda_policy.arn
}
resource "aws_iam_role_policy_attachment" "vehicles_lambda_logs_attach" {
  role       = aws_iam_role.vehicles_lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
resource "aws_iam_role_policy_attachment" "vehicles_lambda_vpc_attach" {
  role       = aws_iam_role.vehicles_lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole" # Essencial para VPC
}