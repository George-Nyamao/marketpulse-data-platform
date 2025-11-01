module "vpc" {
  source = "../../modules/vpc"

  project_name       = var.project_name
  environment        = terraform.workspace
  vpc_cidr           = var.vpc_cidr
  availability_zones = var.availability_zones
}

module "s3" {
  source = "../../modules/s3"

  project_name       = var.project_name
  environment        = terraform.workspace
  bucket_suffix      = "moraran"
  enable_versioning  = true
  raw_lifecycle_days = 90
  logs_retention_days = 30
}

module "glue" {
  source = "../../modules/glue"

  project_name        = var.project_name
  environment         = terraform.workspace
  raw_bucket_name     = module.s3.raw_bucket_name
  silver_bucket_name  = module.s3.silver_bucket_name
  gold_bucket_name    = module.s3.gold_bucket_name
}
