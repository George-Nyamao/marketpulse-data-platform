# KMS Key for Glue/EMR encryption
resource "aws_kms_key" "glue_encryption" {
  description             = "KMS key for Glue and EMR encryption"
  deletion_window_in_days = 10
  enable_key_rotation     = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "EnableIAMRootUserAccess"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "AllowGlueServiceRoleToUseKey"
        Effect = "Allow"
        Principal = {
          AWS = module.iam.glue_service_role_arn
        }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ]
        Resource = "*"
      },
      {
        Sid    = "AllowEMRServiceRoleToUseKey"
        Effect = "Allow"
        Principal = {
          AWS = module.iam.emr_ec2_role_arn
        }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ]
        Resource = "*"
      }
    ]
  })

  tags = {
    Name        = "${var.project_name}-prod-glue-encryption-key"
    Environment = "prod"
  }
}

# KMS Key Alias
resource "aws_kms_alias" "glue_encryption" {
  name          = "alias/${var.project_name}-prod-glue-encryption-key"
  target_key_id = aws_kms_key.glue_encryption.key_id
}
