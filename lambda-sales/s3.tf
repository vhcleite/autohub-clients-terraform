# terraform/lambda-sales/s3.tf

resource "aws_s3_object" "sales_lambda_jar_upload" {
  bucket = data.terraform_remote_state.s3_artifacts.outputs.lambda_deploy_bucket_id

  # Chave mais genérica para o JAR desta API
  key = "${var.environment}/AutoHubSalesApi.jar"

  source = var.lambda_jar_path
  etag   = filemd5(var.lambda_jar_path)

  tags = merge(var.project_tags, { Name = "${var.lambda_function_name_http}-${var.environment}-jar" }) 
}
