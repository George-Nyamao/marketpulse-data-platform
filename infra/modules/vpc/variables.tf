variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment (dev/stg/prod)"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
}

variable "availability_zones" {
  description = "List of AZs"
  type        = list(string)
}

variable "raw_bucket_arn" {
  description = "ARN of the raw S3 bucket"
  type        = string
}

variable "silver_bucket_arn" {
  description = "ARN of the silver S3 bucket"
  type        = string
}

variable "gold_bucket_arn" {
  description = "ARN of the gold S3 bucket"
  type        = string
}

variable "logs_bucket_arn" {
  description = "ARN of the logs S3 bucket"
  type        = string
}

variable "artifacts_bucket_arn" {
  description = "ARN of the artifacts S3 bucket"
  type        = string
}
