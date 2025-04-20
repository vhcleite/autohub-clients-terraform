resource "aws_cloudwatch_log_group" "sales_lambda_log_group" {
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

resource "aws_lambda_function" "sales_api_handler" {
  function_name = "${var.lambda_function_name}-${var.environment}"
  role          = aws_iam_role.sales_lambda_exec_role.arn
  package_type  = "Zip" # Implícito para S3 source, mas explícito

  s3_bucket         = data.terraform_remote_state.s3_artifacts.outputs.lambda_deploy_bucket_id
  s3_key            = aws_s3_object.sales_lambda_jar_upload.key
  s3_object_version = aws_s3_object.sales_lambda_jar_upload.version_id

  handler       = var.lambda_handler # Handler Java (StreamLambdaHandler da Sales API)
  runtime       = var.lambda_runtime
  memory_size   = var.lambda_memory_size
  timeout       = var.lambda_timeout
  architectures = ["arm64"] # Use ARM64 (Graviton) para melhor custo-benefício

  # Configuração de Rede (IMPORTANTE para acessar RDS privado)
  vpc_config {
    # Precisa dos IDs das subnets privadas (lidas do remote state do RDS ou passadas como var)
    subnet_ids = data.terraform_remote_state.rds_sales.outputs.db_subnet_group_subnet_ids # Usa o novo output
    # Precisa do ID do SG da Lambda (criado em iam.tf)
    security_group_ids = [aws_security_group.sales_lambda_sg.id]
  }

  environment {
    variables = {
      # Dados de conexão RDS lidos do remote state 'rds-sales'
      DB_HOST                = data.terraform_remote_state.rds_sales.outputs.sales_db_instance_endpoint
      DB_PORT                = tostring(data.terraform_remote_state.rds_sales.outputs.sales_db_instance_port)
      DB_NAME                = data.terraform_remote_state.rds_sales.outputs.sales_db_instance_name
      DB_USER                = data.terraform_remote_state.rds_sales.outputs.sales_db_instance_username
      DB_PASSWORD_SECRET_ARN = data.terraform_remote_state.rds_sales.outputs.sales_db_password_secret_arn
      # Issuer do Cognito (para Spring Security)
      SPRING_SECURITY_OAUTH2_RESOURCESERVER_JWT_ISSUER_URI = data.terraform_remote_state.cognito.outputs.cognito_user_pool_issuer
      # Perfil Spring
      SPRING_PROFILES_ACTIVE = "prod"
      # Outras...
    }
  }
  publish = true
  # snap_start = {} # SnapStart desabilitado por enquanto

  # Depende da Role e do Log Group
  depends_on = [
    aws_iam_role_policy_attachment.sales_lambda_policy_attach,
    aws_iam_role_policy_attachment.sales_lambda_logs_attach,
    aws_iam_role_policy_attachment.sales_lambda_vpc_attach,
    aws_cloudwatch_log_group.sales_lambda_log_group
  ]
  tags = { /* ... */ }
}

# Permissão para API Gateway invocar esta Lambda
resource "aws_lambda_permission" "sales_api_gw_permission" {
  statement_id  = "AllowAPIGatewayInvokeSalesAPI"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.sales_api_handler.function_name
  principal     = "apigateway.amazonaws.com"
  # Source ARN usa o ARN de execução da API GW compartilhada lido do remote state
  # Restringir ao path /sales/* é uma boa prática
  # source_arn = "${data.terraform_remote_state.api_gateway.outputs.api_gateway_execution_arn}/*/POST/sales" # Exemplo para POST /sales
  source_arn = "${data.terraform_remote_state.api_gateway.outputs.api_gateway_execution_arn}/*/*" # Mais genérico
}