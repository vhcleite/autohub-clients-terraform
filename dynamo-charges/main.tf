terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

resource "aws_dynamodb_table" "charges_table" {
  name = "${var.charges_table_name}-${var.environment}"
  # Modo de capacidade provisionada (alternativa: BILLING_MODE = "PAY_PER_REQUEST")
  billing_mode = "PAY_PER_REQUEST"

  # Definição da Chave de Partição (PK)
  hash_key = "charge_id"

  # Definição dos atributos usados nas chaves (PK e GSI)
  attribute {
    name = "charge_id" # Chave de Partição da tabela
    type = "S"         # S = String
  }
  attribute {
    name = "sale_id" # Chave de Partição do GSI
    type = "S"       # UUID será armazenado como String
  }

  # Definição do Índice Secundário Global (GSI) para buscar por sale_id
  global_secondary_index {
    name            = var.gsi_sale_id_name
    hash_key        = "sale_id"
    projection_type = "ALL"
  }

  tags = merge(
    var.project_tags,
    {
      Name        = "${var.charges_table_name}-${var.environment}"
      Environment = var.environment
    }
  )
}

