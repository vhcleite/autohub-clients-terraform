# terraform/messaging/backend.tf

terraform {
  backend "s3" {
    bucket         = "vhc-terraform-state-autohub-clients-v1"
    key            = "messaging/dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "TerraformStateLockAutoHub"
    encrypt        = true
  }
}
