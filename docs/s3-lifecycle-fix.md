# S3 Lifecycle Rule Fix

## Issue:
Terraform warning about missing `filter` attribute in lifecycle rules.

## Solution:
Add `filter {}` block after `status = "Enabled"` in both:
- aws_s3_bucket_lifecycle_configuration.raw
- aws_s3_bucket_lifecycle_configuration.logs

## Corrected main.tf:
[paste the corrected main.tf I provided earlier]
