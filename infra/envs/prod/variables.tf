variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.1.0.0/16"
}

variable "availability_zones" {
  description = "AZs for subnets"
  type        = list(string)
  default     = ["us-east-2a", "us-east-2b"]
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "marketpulse"
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-2"
}
