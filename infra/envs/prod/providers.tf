terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region  = "us-east-2"
  profile = "marketpulse-prod"

  default_tags {
    tags = {
      Project     = "MarketPulse"
      Environment = "prod"
      ManagedBy   = "Terraform"
      Owner       = "moraran"
      Account     = "production"
    }
  }
}

provider "aws" {
  alias   = "dev"
  region  = "us-east-2"
  profile = "marketpulse"
}
