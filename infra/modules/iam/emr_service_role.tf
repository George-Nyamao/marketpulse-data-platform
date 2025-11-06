# EMR Service Role (for cluster management)
resource "aws_iam_role" "emr_service" {
  name               = "${var.project_name}-${var.environment}-emr-service-role"
  assume_role_policy = data.aws_iam_policy_document.emr_service_assume_role.json

  tags = {
    Name        = "${var.project_name}-${var.environment}-emr-service-role"
    Environment = var.environment
    Service     = "EMR"
  }
}

data "aws_iam_policy_document" "emr_service_assume_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["elasticmapreduce.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

# Attach AWS managed policy for EMR service
resource "aws_iam_role_policy_attachment" "emr_service" {
  role       = aws_iam_role.emr_service.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEMRServicePolicy_v2"
}

# Broad EC2 permissions for EMR cluster operations (development pattern)
resource "aws_iam_role_policy" "emr_service_ec2_full" {
  name   = "emr-service-ec2-full"
  role   = aws_iam_role.emr_service.id
  policy = data.aws_iam_policy_document.emr_service_ec2_policy.json
}

data "aws_iam_policy_document" "emr_service_ec2_policy" {
  # Full EC2 permissions for EMR
  statement {
    sid       = "AllowEC2ForEMR"
    effect    = "Allow"
    actions   = ["ec2:*"]
    resources = ["*"]
  }

  # IAM PassRole for EC2 instance profile
  statement {
    sid    = "AllowPassRoleToEC2"
    effect = "Allow"
    actions = [
      "iam:PassRole"
    ]
    resources = ["arn:aws:iam::${var.account_id}:role/${var.project_name}-${var.environment}-emr-ec2-role"]
    condition {
      test     = "StringEquals"
      variable = "iam:PassedToService"
      values   = ["ec2.amazonaws.com"]
    }
  }
}
