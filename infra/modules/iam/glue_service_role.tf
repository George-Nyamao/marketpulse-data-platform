# Glue Service Role
resource "aws_iam_role" "glue_service" {
  name               = "${var.project_name}-${var.environment}-glue-service-role"
  assume_role_policy = data.aws_iam_policy_document.glue_assume_role.json

  tags = {
    Name        = "${var.project_name}-${var.environment}-glue-service-role"
    Environment = var.environment
    Service     = "Glue"
  }
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_iam_policy_document" "glue_assume_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["glue.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

# Least-privilege policy for Glue
resource "aws_iam_role_policy" "glue_service" {
  name   = "glue-service-policy"
  role   = aws_iam_role.glue_service.id
  policy = data.aws_iam_policy_document.glue_service_policy.json
}

data "aws_iam_policy_document" "glue_service_policy" {
  # Read raw bucket (Bronze)
  statement {
    sid    = "ReadRawBucket"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:ListBucket"
    ]
    resources = [
      var.raw_bucket_arn,
      "${var.raw_bucket_arn}/*"
    ]
  }

  # Read/Write silver and gold buckets
  statement {
    sid    = "ReadWriteSilverGold"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:ListBucket"
    ]
    resources = [
      var.silver_bucket_arn,
      "${var.silver_bucket_arn}/*",
      var.gold_bucket_arn,
      "${var.gold_bucket_arn}/*"
    ]
  }

  # Write logs
  statement {
    sid    = "WriteLogs"
    effect = "Allow"
    actions = [
      "s3:PutObject"
    ]
    resources = [
      "${var.logs_bucket_arn}/glue-logs/*"
    ]
  }

  # Glue Catalog permissions
  statement {
    sid    = "GlueCatalog"
    effect = "Allow"
    actions = [
      "glue:GetDatabase",
      "glue:GetTable",
      "glue:GetPartitions",
      "glue:CreateTable",
      "glue:UpdateTable",
      "glue:CreatePartition",
      "glue:BatchCreatePartition"
    ]
    resources = [
      "arn:aws:glue:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:catalog",
      "arn:aws:glue:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:database/${var.project_name}_${var.environment}_*",
      "arn:aws:glue:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:table/${var.project_name}_${var.environment}_*/*"
    ]
  }

  # CloudWatch Logs
  statement {
    sid    = "CloudWatchLogs"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws-glue/jobs/*",
      "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws-glue/jobs/*:log-stream:*"
    ]
  }

  # KMS Permissions
  statement {
    sid    = "KmsPermissions"
    effect = "Allow"
    actions = [
      "kms:Encrypt",
      "kms:GenerateDataKey*",
      "kms:Decrypt",
      "kms:DescribeKey"
    ]
    resources = [var.kms_key_arn]
  }
}

