# EMR-Managed Security Groups
# EMR will automatically add rules to these groups, but we need to create them first
# for Terraform to reference them

resource "aws_security_group" "emr_master" {
  name_prefix = "${var.project_name}-${var.environment}-emr-master-"
  description = "Security group for EMR master node (managed by EMR)"
  vpc_id      = var.vpc_id

  # EMR will add rules automatically
  # We allow all outbound for now - EMR will restrict as needed
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound (EMR will manage)"
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-emr-master-sg"
    Environment = var.environment
    ManagedBy   = "Terraform/EMR"
  }

  lifecycle {
    ignore_changes = [ingress, egress]
  }
}

resource "aws_security_group" "emr_slave" {
  name_prefix = "${var.project_name}-${var.environment}-emr-slave-"
  description = "Security group for EMR core/task nodes (managed by EMR)"
  vpc_id      = var.vpc_id

  # EMR will add rules automatically
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound (EMR will manage)"
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-emr-slave-sg"
    Environment = var.environment
    ManagedBy   = "Terraform/EMR"
  }

  lifecycle {
    ignore_changes = [ingress, egress]
  }
}

resource "aws_security_group" "emr_service_access" {
  name_prefix = "${var.project_name}-${var.environment}-emr-service-access-"
  description = "Security group for EMR service access (managed by EMR)"
  vpc_id      = var.vpc_id

  # EMR will add rules automatically
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound (EMR will manage)"
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-emr-service-access-sg"
    Environment = var.environment
    ManagedBy   = "Terraform/EMR"
  }

  lifecycle {
    ignore_changes = [ingress, egress]
  }
}

# Required: Service access SG must allow inbound from master SG on port 9443
# Created as separate resource to work with lifecycle ignore_changes
resource "aws_security_group_rule" "emr_service_access_from_master" {
  type                     = "ingress"
  from_port                = 9443
  to_port                  = 9443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.emr_master.id
  security_group_id        = aws_security_group.emr_service_access.id
  description              = "Allow EMR service access from master node"
}

# Also allow from slave nodes for service access
resource "aws_security_group_rule" "emr_service_access_from_slave" {
  type                     = "ingress"
  from_port                = 9443
  to_port                  = 9443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.emr_slave.id
  security_group_id        = aws_security_group.emr_service_access.id
  description              = "Allow EMR service access from slave nodes"
}
