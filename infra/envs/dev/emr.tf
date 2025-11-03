module "emr" {
  source = "../../modules/emr"

  project_name                     = var.project_name
  environment                      = terraform.workspace
  subnet_ids                       = module.vpc.private_subnet_ids
  vpc_id                           = module.vpc.vpc_id
  emr_service_role_name            = module.iam.emr_service_role_name
  emr_ec2_instance_profile_name    = module.iam.emr_ec2_instance_profile_name
  logs_bucket                      = module.s3.logs_bucket_name
  master_instance_type             = "m5.xlarge"
  core_instance_type               = "m5.xlarge"
  core_instance_count              = 2
  auto_termination_idle_timeout    = 1800
}
