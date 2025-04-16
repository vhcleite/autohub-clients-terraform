# --- IAM Role para a Função Lambda ---
resource "aws_iam_role" "lambda_exec_role" {
  # Nome da role na AWS
  name = "${var.lambda_function_name}-${var.environment}-exec-role"

  # Política de Confiança: Define QUEM pode assumir esta role.
  # Neste caso, permitimos que o serviço Lambda (lambda.amazonaws.com) assuma a role.
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

# --- Política IAM Customizada para Acesso ao DynamoDB ---
resource "aws_iam_policy" "dynamodb_access_policy" {
  name        = "${var.lambda_function_name}-${var.environment}-dynamodb-policy"
  description = "Permite que o Lambda acesse a tabela de usuários do DynamoDB"

  # Definição da Política em JSON
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowDynamoDBAccess" # Identificador da declaração
        Effect = "Allow"               # Permitir as ações
        Action = [                     # Lista de ações permitidas no DynamoDB
          "dynamodb:PutItem",          # Para salvar/criar usuário
          "dynamodb:GetItem",          # Para buscar usuário por ID
          "dynamodb:UpdateItem",       # Necessário se usar operações de update específicas
          "dynamodb:DeleteItem",       # Para deletar usuário
          "dynamodb:Query",            # Para consultar o índice secundário (GSI) por email
          # "dynamodb:Scan"          # Evitar Scan se possível, é ineficiente
        ]
        # Recurso: Especifica SOBRE QUAL tabela as ações são permitidas
        # Usamos o ARN da tabela obtido do estado remoto do módulo 'database'
        Resource = [
          data.terraform_remote_state.database.outputs.dynamodb_user_table_arn,
          # Também precisa de permissão no ARN do Índice Secundário para Query
          "${data.terraform_remote_state.database.outputs.dynamodb_user_table_arn}/index/${data.terraform_remote_state.database.outputs.dynamodb_user_table_email_index_name}"
        ]
      },
    ]
  })
}

# --- Anexar a Política Customizada à Role do Lambda ---
resource "aws_iam_role_policy_attachment" "dynamodb_attach" {
  role       = aws_iam_role.lambda_exec_role.name        # Nome da Role
  policy_arn = aws_iam_policy.dynamodb_access_policy.arn # ARN da política que criamos
}

# --- Anexar Política Gerenciada pela AWS para Logs Básicos ---
# Esta política padrão permite que o Lambda crie Log Groups e Log Streams
# e envie logs para o CloudWatch Logs. Essencial para debugging.
resource "aws_iam_role_policy_attachment" "lambda_logs_attach" {
  role = aws_iam_role.lambda_exec_role.name
  # ARN de uma política já existente e gerenciada pela AWS
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}