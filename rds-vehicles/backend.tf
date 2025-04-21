terraform {
  backend "s3" {
    bucket         = "vhc-terraform-state-autohub-clients-v1"
    key            = "rds-vehicles/dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "TerraformStateLockAutoHub"
    encrypt        = true
  }
}