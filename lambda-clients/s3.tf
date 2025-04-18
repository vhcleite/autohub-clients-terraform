resource "aws_s3_object" "clients_lambda_jar_upload" {
  # Nome do bucket lido de variável ou remote state (precisa existir!)
  bucket = data.terraform_remote_state.s3_artifacts.outputs.lambda_deploy_bucket_id

  # Chave específica para o JAR da API de Clientes neste ambiente
  key = "${var.environment}/${var.lambda_function_name}.jar"

  source = var.lambda_jar_path          # Path para o JAR local desta API
  etag   = filemd5(var.lambda_jar_path) # Upload só se o JAR mudar

  tags = merge(
    var.project_tags,
    {
      Environment = var.environment
    }
  )
}