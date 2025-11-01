variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment"
  type        = string
}

variable "raw_bucket_name" {
  description = "Raw S3 bucket name"
  type        = string
}

variable "silver_bucket_name" {
  description = "Silver S3 bucket name"
  type        = string
}

variable "gold_bucket_name" {
  description = "Gold S3 bucket name"
  type        = string
}
