module "vpc" {
  source = "../../modules/vpc"

  project_name       = var.project_name
  environment        = terraform.workspace
  vpc_cidr           = var.vpc_cidr
  availability_zones = var.availability_zones
}
