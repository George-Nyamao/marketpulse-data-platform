terraform {
  backend "s3" {
    bucket         = "tfstate-moraran-global"
    key            = "marketpulse/dev/terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "terraform-state-locks"
    encrypt        = true
    profile        = "marketpulse"
  }
}
