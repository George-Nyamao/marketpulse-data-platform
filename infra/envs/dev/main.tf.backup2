module "vpc" {
  source = "../../modules/vpc"

  project_name         = var.project_name
  environment          = terraform.workspace
  vpc_cidr             = var.vpc_cidr
  availability_zones   = var.availability_zones
  raw_bucket_arn       = module.s3.raw_bucket_arn
  silver_bucket_arn    = module.s3.silver_bucket_arn
  gold_bucket_arn      = module.s3.gold_bucket_arn
  logs_bucket_arn      = module.s3.logs_bucket_arn
  artifacts_bucket_arn = module.s3.artifacts_bucket_arn
}

data "aws_caller_identity" "current" {}

module "s3" {
  source = "../../modules/s3"

  project_name          = var.project_name
  environment           = terraform.workspace
  bucket_suffix         = "moraran"
  enable_versioning     = true
  raw_lifecycle_days    = 30
  logs_retention_days   = 30
  s3_endpoint_id        = module.vpc.s3_endpoint_id
  allowed_deployer_arns = [data.aws_caller_identity.current.arn]
}

module "glue" {
  source = "../../modules/glue"

  project_name       = var.project_name
  environment        = terraform.workspace
  raw_bucket_name    = module.s3.raw_bucket_name
  silver_bucket_name = module.s3.silver_bucket_name
  gold_bucket_name   = module.s3.gold_bucket_name
}

module "iam" {
  source = "../../modules/iam"

  project_name      = var.project_name
  environment       = terraform.workspace
  raw_bucket_arn    = module.s3.raw_bucket_arn
  silver_bucket_arn = module.s3.silver_bucket_arn
  gold_bucket_arn   = module.s3.gold_bucket_arn
  logs_bucket_arn   = module.s3.logs_bucket_arn
  kms_key_arn       = aws_kms_key.glue_encryption.arn
}
