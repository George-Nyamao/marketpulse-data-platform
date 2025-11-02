output "glue_service_role_arn" {
  description = "ARN of Glue service role"
  value       = aws_iam_role.glue_service.arn
}

output "glue_service_role_name" {
  description = "Name of Glue service role"
  value       = aws_iam_role.glue_service.name
}
