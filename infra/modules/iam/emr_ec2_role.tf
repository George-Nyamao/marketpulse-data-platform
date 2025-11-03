# EMR EC2 Role (for cluster nodes)
resource "aws_iam_role" "emr_ec2" {
  name               = "${var.project_name}-${var.environment}-emr-ec2-role"
  assume_role_policy = data.aws_iam_policy_document.emr_ec2_assume_role.json

  tags = {
    Name        = "${var.project_name}-${var.environment}-emr-ec2-role"
    Environment = var.environment
    Service     = "EMR"
  }
}

data "aws_iam_policy_document" "emr_ec2_assume_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

# Instance Profile
resource "aws_iam_instance_profile" "emr_ec2" {
  name = "${var.project_name}-${var.environment}-emr-ec2-profile"
  role = aws_iam_role.emr_ec2.name
}

# Custom policy for S3 and KMS access
resource "aws_iam_role_policy" "emr_ec2" {
  name   = "emr-ec2-policy"
  role   = aws_iam_role.emr_ec2.id
  policy = data.aws_iam_policy_document.emr_ec2_policy.json
}

data "aws_iam_policy_document" "emr_ec2_policy" {
  # Read from raw bucket
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

  # Read artifacts bucket
  statement {
    sid    = "ReadArtifacts"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:ListBucket"
    ]
    resources = [
      var.artifacts_bucket_arn,
      "${var.artifacts_bucket_arn}/*"
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
      "${var.logs_bucket_arn}/emr/*"
    ]
  }

  # Glue Catalog access
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
      "arn:aws:glue:${var.region}:${var.account_id}:catalog",
      "arn:aws:glue:${var.region}:${var.account_id}:database/marketpulse_${var.environment}_*",
      "arn:aws:glue:${var.region}:${var.account_id}:table/marketpulse_${var.environment}_*/*"
    ]
  }

  # CloudWatch Logs
  statement {
    sid    = "CloudWatchLogs"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogStreams"
    ]
    resources = [
      "arn:aws:logs:${var.region}:${var.account_id}:log-group:/aws/emr/*"
    ]
  }

  # KMS permissions
  statement {
    sid    = "KmsPermissions"
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:DescribeKey",
      "kms:Encrypt",
      "kms:GenerateDataKey*",
      "kms:ReEncrypt*"
    ]
    resources = [
      var.kms_key_arn
    ]
  }
}
