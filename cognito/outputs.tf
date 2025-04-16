# terraform/cognito/outputs.tf

output "cognito_user_pool_id" {
  description = "O ID do Cognito User Pool criado"
  value       = aws_cognito_user_pool.main.id
}

output "cognito_user_pool_arn" {
  description = "O ARN (Amazon Resource Name) do Cognito User Pool criado"
  value       = aws_cognito_user_pool.main.arn
}

output "cognito_user_pool_endpoint" {
  description = "O endpoint do Cognito User Pool (usado por alguns SDKs)"
  value       = aws_cognito_user_pool.main.endpoint
}

output "cognito_user_pool_client_id" {
  description = "O ID do App Client criado para o User Pool"
  value       = aws_cognito_user_pool_client.app_client.id
}

output "cognito_hosted_ui_domain" {
  description = "A URL base completa do domínio configurado para a Hosted UI"
  value       = "https://${aws_cognito_user_pool_domain.main.domain}.auth.${data.aws_region.current.name}.amazoncognito.com"
}

output "cognito_user_pool_issuer" {
  description = "O Issuer URI do User Pool (necessário para validação JWT no backend)"
  value       = "https://cognito-idp.${var.aws_region}.amazonaws.com/${aws_cognito_user_pool.main.id}"
}