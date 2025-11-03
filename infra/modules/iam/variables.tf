variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "raw_bucket_arn" {
  description = "ARN of raw bucket"
  type        = string
}

variable "silver_bucket_arn" {
  description = "ARN of silver bucket"
  type        = string
}

variable "gold_bucket_arn" {
  description = "ARN of gold bucket"
  type        = string
}

variable "logs_bucket_arn" {
  description = "ARN of logs bucket"
  type        = string
}

variable "kms_key_arn" {
  description = "ARN of the KMS key"
  type        = string
}
