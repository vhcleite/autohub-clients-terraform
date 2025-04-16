# --- Log Group para a Função Lambda ---
resource "aws_cloudwatch_log_group" "lambda_log_group" {
  # O nome do log group segue um padrão do Lambda
  name              = "/aws/lambda/${var.lambda_function_name}-${var.environment}"
  retention_in_days = 1

  tags = merge(
    var.project_tags,
    {
      Name        = "/aws/lambda/${var.lambda_function_name}-${var.environment}"
      Environment = var.environment
    }
  )
}

# --- Função Lambda ---
resource "aws_lambda_function" "api_handler" {
  # Nome da função na AWS
  function_name = "${var.lambda_function_name}-${var.environment}"
  # ARN da Role IAM que a função usará (criada em iam.tf)
  role = aws_iam_role.lambda_exec_role.arn

  # Adicione estas linhas para apontar para o objeto S3
  s3_bucket         = aws_s3_bucket.lambda_deployments.id # Nome do bucket S3
  s3_key            = aws_s3_object.lambda_jar_upload.key # Chave do objeto S3 (o path do JAR no bucket)
  s3_object_version = aws_s3_object.lambda_jar_upload.version_id


  # --- Configuração do Runtime ---
  handler = var.lambda_handler # O handler do Spring Cloud Function Adapter
  runtime = var.lambda_runtime # Ex: "java21" ou "java17"

  # --- Recursos ---
  memory_size = var.lambda_memory_size # Memória em MB
  timeout     = var.lambda_timeout     # Timeout em segundos

  # --- Variáveis de Ambiente para a Aplicação ---
  environment {
    variables = {
      # Passa o nome da tabela DynamoDB para a aplicação (lido via @Value por exemplo)
      DYNAMODB_TABLE_NAME = data.terraform_remote_state.database.outputs.dynamodb_user_table_name
      # Define o perfil Spring ativo para a execução na AWS (ex: 'prod' ou 'aws')
      SPRING_PROFILES_ACTIVE = "prod"
      # Adicione outras variáveis necessárias aqui (ex: COGNITO_ISSUER_URI se não pegar do yml)
      # JAVA_TOOL_OPTIONS: "-XX:+TieredCompilation -XX:TieredStopAtLevel=1" # Otimização comum para Java Lambda

      # --- Adicionar/Modificar estas linhas ---
      LOGGING_LEVEL_ORG_SPRINGFRAMEWORK = "DEBUG"
    LOGGING_LEVEL_ORG_SPRINGFRAMEWORK_CLOUD_FUNCTION = "DEBUG" # Embora não usemos mais SC Func diretamente, não custa deixar
    LOGGING_LEVEL_ROOT = "DEBUG" # Para pegar logs mais gerais do Lambda/Java talvez
  }
  }

  # --- SnapStart (Otimização para Java) ---
  # Reduz significativamente cold starts para runtimes Java
  # snap_start {
  #   apply_on = "PublishedVersions" # Ativa para versões publicadas da função
  # }

  # --- Versionamento ---
  # Cria uma nova versão da função a cada deploy do código/configuração.
  # Necessário para SnapStart e para usar Aliases.
  publish = true

  # Depende explicitamente do Log Group para garantir que ele exista
  depends_on = [aws_cloudwatch_log_group.lambda_log_group]

  tags = merge(
    var.project_tags,
    {
      Name        = "${var.lambda_function_name}-${var.environment}"
      Environment = var.environment
    }
  )
}

# --- Permissão para o API Gateway Invocar o Lambda ---
resource "aws_lambda_permission" "api_gw_permission" {
  statement_id  = "AllowAPIGatewayInvoke"                       # Um ID para a declaração da permissão
  action        = "lambda:InvokeFunction"                       # A permissão para invocar
  function_name = aws_lambda_function.api_handler.function_name # O nome da função Lambda
  principal     = "apigateway.amazonaws.com"                    # O serviço que pode invocar (API Gateway)

  # IMPORTANTE: Restringe qual API Gateway pode invocar esta função.
  # Usamos o ARN de execução da API Gateway que será criada em apigateway.tf
  # O '*' no final permite qualquer método/recurso dentro dessa API específica.
  source_arn = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*"
}
