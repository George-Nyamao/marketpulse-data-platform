# EMR Cluster
resource "aws_emr_cluster" "main" {
  name          = "${var.project_name}-${var.environment}-emr-cluster"
  release_label = var.emr_release
  applications  = ["Hadoop", "Spark"]

  service_role = var.emr_service_role_name

  ec2_attributes {
    subnet_id                         = var.subnet_ids[0]
    emr_managed_master_security_group = aws_security_group.emr_master.id
    emr_managed_slave_security_group  = aws_security_group.emr_slave.id
    service_access_security_group     = aws_security_group.emr_service_access.id
    instance_profile                  = var.emr_ec2_instance_profile_name
    key_name                          = var.key_name
  }

  master_instance_group {
    instance_type = var.master_instance_type
    instance_count = 1
  }

  core_instance_group {
    instance_type  = var.core_instance_type
    instance_count = var.core_instance_count
    
    ebs_config {
      size                 = 32
      type                 = "gp3"
      volumes_per_instance = 1
    }
  }

  log_uri = "s3://${var.logs_bucket}/emr/"

  configurations_json = jsonencode([
    {
      Classification = "spark"
      Properties = {
        "maximizeResourceAllocation" = "true"
      }
    },
    {
      Classification = "spark-defaults"
      Properties = {
        "spark.dynamicAllocation.enabled" = "true"
        "spark.shuffle.service.enabled"   = "true"
      }
    }
  ])

  auto_termination_policy {
    idle_timeout = var.auto_termination_idle_timeout
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-emr-cluster"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}
