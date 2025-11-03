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
