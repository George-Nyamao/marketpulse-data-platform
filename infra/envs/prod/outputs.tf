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

# IAM Outputs
output "glue_service_role_arn" {
  description = "Glue service role ARN"
  value       = module.iam.glue_service_role_arn
}

output "glue_service_role_name" {
  description = "Glue service role name"
  value       = module.iam.glue_service_role_name
}

# KMS Outputs
output "kms_key_id" {
  description = "KMS key ID for Glue encryption"
  value       = aws_kms_key.glue_encryption.id
}

output "kms_key_arn" {
  description = "KMS key ARN for Glue encryption"
  value       = aws_kms_key.glue_encryption.arn
}

output "kms_alias_name" {
  description = "KMS key alias name"
  value       = aws_kms_alias.glue_encryption.name
}

# EMR IAM Outputs
output "emr_service_role_arn" {
  description = "EMR service role ARN"
  value       = module.iam.emr_service_role_arn
}

output "emr_service_role_name" {
  description = "EMR service role name"
  value       = module.iam.emr_service_role_name
}

output "emr_ec2_instance_profile_arn" {
  description = "EMR EC2 instance profile ARN"
  value       = module.iam.emr_ec2_instance_profile_arn
}

output "emr_ec2_instance_profile_name" {
  description = "EMR EC2 instance profile name"
  value       = module.iam.emr_ec2_instance_profile_name
}

# EMR Cluster Outputs
output "emr_cluster_id" {
  description = "EMR cluster ID"
  value       = module.emr.cluster_id
}

output "emr_cluster_name" {
  description = "EMR cluster name"
  value       = module.emr.cluster_name
}

output "emr_master_security_group_id" {
  description = "EMR master security group ID"
  value       = module.emr.master_security_group_id
}

# EMR Managed Scaling
output "emr_managed_scaling_policy_id" {
  description = "EMR managed scaling policy ID"
  value       = module.emr.emr_managed_scaling_policy_id
}
