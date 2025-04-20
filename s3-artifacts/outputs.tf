output "lambda_deploy_bucket_id" {
  description = "O ID (nome) do bucket S3 para deploy Lambda"
  value       = aws_s3_bucket.lambda_deployments.id
}

output "lambda_deploy_bucket_arn" {
  description = "O ARN do bucket S3 para deploy Lambda"
  value       = aws_s3_bucket.lambda_deployments.arn
}