output "glue_service_role_arn" {
  description = "ARN of Glue service role"
  value       = aws_iam_role.glue_service.arn
}

output "glue_service_role_name" {
  description = "Name of Glue service role"
  value       = aws_iam_role.glue_service.name
}

# EMR Service Role
output "emr_service_role_arn" {
  description = "ARN of EMR service role"
  value       = aws_iam_role.emr_service.arn
}

output "emr_service_role_name" {
  description = "Name of EMR service role"
  value       = aws_iam_role.emr_service.name
}

# EMR EC2 Role
output "emr_ec2_role_arn" {
  description = "ARN of EMR EC2 role"
  value       = aws_iam_role.emr_ec2.arn
}

output "emr_ec2_instance_profile_arn" {
  description = "ARN of EMR EC2 instance profile"
  value       = aws_iam_instance_profile.emr_ec2.arn
}

output "emr_ec2_instance_profile_name" {
  description = "Name of EMR EC2 instance profile"
  value       = aws_iam_instance_profile.emr_ec2.name
}
