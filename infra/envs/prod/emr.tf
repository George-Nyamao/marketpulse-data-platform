module "emr" {
  source = "../../modules/emr"

  project_name                     = var.project_name
  environment                      = "prod"
  subnet_ids                       = module.vpc.private_subnet_ids
  vpc_id                           = module.vpc.vpc_id
  emr_service_role_name            = module.iam.emr_service_role_name
  emr_ec2_instance_profile_name    = module.iam.emr_ec2_instance_profile_name
  logs_bucket                      = module.s3.logs_bucket_name
  master_instance_type             = "m5.xlarge"
  core_instance_type               = "m5.xlarge"
  core_instance_count              = 2
  task_instance_count              = 0  # Start with 0, managed scaling will add task nodes
  auto_termination_idle_timeout    = 1800  # 30 minutes
  managed_scaling_min              = 2  # Master + 1 core minimum
  managed_scaling_max              = 10  # Master + 2 cores + 7 tasks maximum
  kms_key_id                       = aws_kms_key.glue_encryption.id  # Optional: for log encryption
  cloudwatch_log_group             = "/aws/emr/marketpulse-prod"  # Optional: CloudWatch log group

  # Optional bootstrap actions - install wheels/jars from artifacts bucket
  # Example (commented out - uncomment and customize as needed):
  # bootstrap_actions = [
  #   {
  #     name = "install-python-packages"
  #     path = "s3://${module.s3.artifacts_bucket_name}/emr/bootstrap/install-packages.sh"
  #     args = ["s3://${module.s3.artifacts_bucket_name}/emr/wheels/"]
  #   }
  # ]
  bootstrap_actions = []
}
