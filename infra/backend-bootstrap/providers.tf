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
  profile = "marketpulse"
  
  default_tags {
    tags = {
      Project     = "MarketPulse"
      ManagedBy   = "Terraform"
      Environment = "global"
      Owner       = "moraran"
    }
  }
}