resource "aws_s3_object" "charges_lambda_jar_upload" {
  bucket = data.terraform_remote_state.s3_artifacts.outputs.lambda_deploy_bucket_id

  # Chave S3 para o JAR da Charges API (consistente com CI/CD)
  key = "${var.environment}/AutoHubChargesApi.jar"

  source = var.lambda_jar_path
  # Força o re-upload se o conteúdo do JAR mudar
  etag = filemd5(var.lambda_jar_path)

  tags = merge(var.project_tags, { Name = "${var.lambda_function_name_http}-${var.environment}-jar" })
}

