# terraform/application/s3-deploy.tf

variable "lambda_deploy_bucket_name" {
  description = "Nome base para o bucket S3 que armazenará os artefatos de deploy do Lambda"
  type        = string
  default     = "autohub-clients-api-lambda-deploy"
}

# No arquivo onde você definiu o aws_s3_bucket.lambda_deployments (ex: s3.tf ou main.tf)

resource "aws_s3_bucket_versioning" "lambda_deployments_versioning" {
  bucket = aws_s3_bucket.lambda_deployments.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket" "lambda_deployments" {
  bucket = "${var.lambda_deploy_bucket_name}-${data.aws_caller_identity.current.account_id}-${var.aws_region}"

  force_destroy = true

  tags = merge(
    var.project_tags,
    {
      Name        = "${var.lambda_deploy_bucket_name}-${var.environment}"
      Environment = var.environment
    }
  )
}

resource "aws_s3_object" "lambda_jar_upload" {
  bucket = aws_s3_bucket.lambda_deployments.id # Referencia o bucket criado acima
  key    = "${var.environment}/${var.lambda_function_name}.jar"
  source = var.lambda_jar_path

  # IMPORTANTE: Etag/Hash do arquivo local.
  # Isso garante que o Terraform só fará o upload para o S3 novamente
  # se o conteúdo do arquivo JAR local mudar.
  etag = filemd5(var.lambda_jar_path)

  tags = merge(
    var.project_tags,
    {
      Environment = var.environment
    }
  )
}