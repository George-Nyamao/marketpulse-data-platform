# EMR Cluster with Instance Fleets and Managed Scaling
resource "aws_emr_cluster" "main" {
  name          = "${var.project_name}-${var.environment}-emr-cluster"
  release_label = "emr-6.15.0"
  applications  = ["Hadoop", "Spark"]

  service_role = var.emr_service_role_name

  ec2_attributes {
    subnet_ids                        = var.subnet_ids
    emr_managed_master_security_group = aws_security_group.emr_master.id
    emr_managed_slave_security_group  = aws_security_group.emr_slave.id
    service_access_security_group     = aws_security_group.emr_service_access.id
    instance_profile                  = var.emr_ec2_instance_profile_name
  }

  # Master Instance Fleet (on-demand only)
  master_instance_fleet {
    name                      = "master-fleet"
    target_on_demand_capacity = 1

    instance_type_configs {
      instance_type = var.master_instance_type

      ebs_config {
        size                 = 32
        type                 = "gp3"
        volumes_per_instance = 1
      }
    }

    launch_specifications {
      on_demand_specification {
        allocation_strategy = "lowest-price"
      }
    }
  }

  # Core Instance Fleet (on-demand baseline)
  core_instance_fleet {
    name                      = "core-fleet"
    target_on_demand_capacity = var.core_instance_count

    instance_type_configs {
      instance_type     = var.core_instance_type
      weighted_capacity = 1

      ebs_config {
        size                 = 32
        type                 = "gp3"
        volumes_per_instance = 1
      }
    }

    launch_specifications {
      on_demand_specification {
        allocation_strategy = "lowest-price"
      }
    }
  }

  # Task Instance Fleet (Spot instances with diversification)
  # Note: Task fleet must be created as separate aws_emr_instance_fleet resource
  # Managed scaling will add task nodes when needed (up to 7 tasks)

  # Spark configuration for optimization
  configurations_json = jsonencode([
    {
      Classification = "spark"
      Properties = {
        maximizeResourceAllocation = "true"
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

  log_uri = "s3://${var.logs_bucket}/emr/"

  # Bootstrap actions (optional - install wheels/jars from artifacts)
  dynamic "bootstrap_action" {
    for_each = var.bootstrap_actions
    content {
      name = bootstrap_action.value.name
      path = bootstrap_action.value.path
      args = bootstrap_action.value.args
    }
  }

  auto_termination_policy {
    idle_timeout = var.auto_termination_idle_timeout
  }

  step_concurrency_level = 1
  visible_to_all_users   = true

  tags = {
    Name        = "${var.project_name}-${var.environment}-emr-cluster"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# Task Instance Fleet (Spot instances with diversification)
# Created as separate resource - managed scaling will add task nodes when needed
# Note: Must have at least 1 capacity (even if 0, AWS requires minimum 1 for fleet creation)
resource "aws_emr_instance_fleet" "task" {
  cluster_id = aws_emr_cluster.main.id
  name       = "task-fleet"

  target_on_demand_capacity = 0
  target_spot_capacity      = max(1, var.task_instance_count)  # AWS requires min 1 for fleet creation

  instance_type_configs {
    instance_type     = "m5.xlarge"
    weighted_capacity = 1

    ebs_config {
      size                 = 32
      type                 = "gp3"
      volumes_per_instance = 1
    }
  }

  instance_type_configs {
    instance_type     = "r5.xlarge"
    weighted_capacity = 1

    ebs_config {
      size                 = 32
      type                 = "gp3"
      volumes_per_instance = 1
    }
  }

  instance_type_configs {
    instance_type     = "c5.xlarge"
    weighted_capacity = 1

    ebs_config {
      size                 = 32
      type                 = "gp3"
      volumes_per_instance = 1
    }
  }

  launch_specifications {
    spot_specification {
      allocation_strategy      = "capacity-optimized"
      timeout_action          = "SWITCH_TO_ON_DEMAND"
      timeout_duration_minutes = 10
    }
  }
}

# Managed Scaling Policy (2-10 instances)
# Min: 2 (master + 1 core), Max: 10 (master + 2 cores + 7 tasks)
# Note: Instance fleets require InstanceFleetUnits, not Instances
resource "aws_emr_managed_scaling_policy" "main" {
  cluster_id = aws_emr_cluster.main.id

  compute_limits {
    unit_type                      = "InstanceFleetUnits"  # Required for instance fleet clusters
    minimum_capacity_units         = var.managed_scaling_min
    maximum_capacity_units         = var.managed_scaling_max
    maximum_ondemand_capacity_units = var.core_instance_count + 1  # Master + core baseline (on-demand only)
    maximum_core_capacity_units     = var.core_instance_count + 1  # Master + cores (exclude tasks)
  }
}
