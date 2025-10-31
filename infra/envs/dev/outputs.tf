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
