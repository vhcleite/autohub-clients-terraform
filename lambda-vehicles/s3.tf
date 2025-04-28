# terraform/lambda-vehicles/s3.tf

resource "aws_s3_object" "vehicles_lambda_jar_upload" {
  # Nome do bucket lido do estado remoto do s3_artifacts
  bucket = data.terraform_remote_state.s3_artifacts.outputs.lambda_deploy_bucket_id

  # Chave específica para o JAR da API de Veículos neste ambiente
  key = "${var.environment}/${var.lambda_function_name}.jar" # Ex: dev/AutoHubVehiclesApi.jar

  # Caminho para o JAR local desta API (passado via -var)
  source = var.lambda_jar_path
  # Força o re-upload se o conteúdo do JAR mudar
  etag = filemd5(var.lambda_jar_path)

  tags = merge(var.project_tags, { Name = "${var.lambda_function_name}-${var.environment}-jar" })
}