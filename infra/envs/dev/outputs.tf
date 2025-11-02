output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = module.vpc.private_subnet_ids
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = module.vpc.public_subnet_ids
}

output "s3_endpoint_id" {
  description = "S3 VPC Endpoint ID"
  value       = module.vpc.s3_endpoint_id
}

output "glue_endpoint_id" {
  description = "Glue VPC Endpoint ID"
  value       = module.vpc.glue_endpoint_id
}

output "logs_endpoint_id" {
  description = "CloudWatch Logs VPC Endpoint ID"
  value       = module.vpc.logs_endpoint_id
}

output "sts_endpoint_id" {
  description = "STS VPC Endpoint ID"
  value       = module.vpc.sts_endpoint_id
}

output "ec2_endpoint_id" {
  description = "EC2 VPC Endpoint ID"
  value       = module.vpc.ec2_endpoint_id
}

output "kms_endpoint_id" {
  description = "KMS VPC Endpoint ID"
  value       = module.vpc.kms_endpoint_id
}

# S3 Outputs
output "raw_bucket" {
  description = "Raw data bucket name"
  value       = module.s3.raw_bucket_name
}

output "silver_bucket" {
  description = "Silver data bucket name"
  value       = module.s3.silver_bucket_name
}

output "gold_bucket" {
  description = "Gold data bucket name"
  value       = module.s3.gold_bucket_name
}

output "logs_bucket" {
  description = "Logs bucket name"
  value       = module.s3.logs_bucket_name
}

output "artifacts_bucket" {
  description = "Artifacts bucket name"
  value       = module.s3.artifacts_bucket_name
}

# Glue Outputs
output "bronze_database" {
  description = "Bronze Glue database name"
  value       = module.glue.bronze_database_name
}

output "silver_database" {
  description = "Silver Glue database name"
  value       = module.glue.silver_database_name
}

output "gold_database" {
  description = "Gold Glue database name"
  value       = module.glue.gold_database_name
}

# IAM Outputs
output "glue_service_role_arn" {
  description = "Glue service role ARN"
  value       = module.iam.glue_service_role_arn
}

output "glue_service_role_name" {
  description = "Glue service role name"
  value       = module.iam.glue_service_role_name
}
