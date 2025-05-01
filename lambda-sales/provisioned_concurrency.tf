# Ficheiro: lambda-sales/provisioned_concurrency.tf

# 1. Cria um Alias chamado 'live' que aponta para a versão mais recente publicada da Lambda SQS
resource "aws_lambda_alias" "sales_sqs_alias_live" {
  name             = "live" # Nome do alias (pode ser qualquer nome descritivo)
  description      = "Alias pointing to the latest published version for SQS handler"
  function_name    = aws_lambda_function.sales_api_sqs_handler.function_name
  function_version = aws_lambda_function.sales_api_sqs_handler.version
}

# 2. Configura Provisioned Concurrency para o Alias 'live'
resource "aws_lambda_provisioned_concurrency_config" "sales_sqs_provisioned" {
  function_name                     = aws_lambda_function.sales_api_sqs_handler.function_name
  qualifier                         = aws_lambda_alias.sales_sqs_alias_live.name
  provisioned_concurrent_executions = 1
  depends_on                        = [aws_lambda_alias.sales_sqs_alias_live]
}

resource "aws_lambda_alias" "sales_http_alias_live" {
  name             = "live"
  description      = "Alias pointing to the latest published version for HTTP handler"
  function_name    = aws_lambda_function.sales_api_http_handler.function_name
  function_version = aws_lambda_function.sales_api_http_handler.version
  depends_on       = [aws_lambda_function.sales_api_http_handler]
}

resource "aws_lambda_provisioned_concurrency_config" "sales_http_provisioned" {
  function_name                     = aws_lambda_function.sales_api_http_handler.function_name
  qualifier                         = aws_lambda_alias.sales_http_alias_live.name
  provisioned_concurrent_executions = 1
  depends_on                        = [aws_lambda_alias.sales_http_alias_live]
}

