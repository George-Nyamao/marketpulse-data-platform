output "raw_bucket_name" {
  description = "Raw data bucket name"
  value       = aws_s3_bucket.raw.id
}

output "raw_bucket_arn" {
  description = "Raw data bucket ARN"
  value       = aws_s3_bucket.raw.arn
}

output "silver_bucket_name" {
  description = "Silver data bucket name"
  value       = aws_s3_bucket.silver.id
}

output "silver_bucket_arn" {
  description = "Silver data bucket ARN"
  value       = aws_s3_bucket.silver.arn
}

output "gold_bucket_name" {
  description = "Gold data bucket name"
  value       = aws_s3_bucket.gold.id
}

output "gold_bucket_arn" {
  description = "Gold data bucket ARN"
  value       = aws_s3_bucket.gold.arn
}

output "logs_bucket_name" {
  description = "Logs bucket name"
  value       = aws_s3_bucket.logs.id
}

output "artifacts_bucket_name" {
  description = "Artifacts bucket name"
  value       = aws_s3_bucket.artifacts.id
}

output "artifacts_bucket_arn" {
  description = "Artifacts bucket ARN"
  value       = aws_s3_bucket.artifacts.arn
}

output "all_bucket_names" {
  description = "Map of all bucket names"
  value = {
    raw       = aws_s3_bucket.raw.id
    silver    = aws_s3_bucket.silver.id
    gold      = aws_s3_bucket.gold.id
    logs      = aws_s3_bucket.logs.id
    artifacts = aws_s3_bucket.artifacts.id
  }
}
