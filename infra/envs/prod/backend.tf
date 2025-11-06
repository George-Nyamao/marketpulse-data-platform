terraform {
  backend "s3" {
    bucket         = "tfstate-moraran-prod-global"
    key            = "marketpulse/prod/terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "terraform-state-locks"
    encrypt        = true
    profile        = "marketpulse-prod"
  }
}
