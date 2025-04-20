resource "aws_s3_object" "sales_lambda_jar_upload" {
  bucket = data.terraform_remote_state.s3_artifacts.outputs.lambda_deploy_bucket_id # Nome do bucket compartilhado
  key    = "${var.environment}/${var.lambda_function_name}.jar"                     # Chave específica
  source = var.lambda_jar_path                                                      # Path para o JAR local da Sales API
  etag   = filemd5(var.lambda_jar_path)
  tags   = { /* ... */ }
}