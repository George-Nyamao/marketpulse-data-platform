# EMR Master Security Group
resource "aws_security_group" "emr_master" {
  name        = "${var.project_name}-${var.environment}-emr-master-sg"
  description = "Security group for EMR master node"
  vpc_id      = var.vpc_id

  tags = {
    Name        = "${var.project_name}-${var.environment}-emr-master-sg"
    Environment = var.environment
  }
}

# EMR Slave Security Group
resource "aws_security_group" "emr_slave" {
  name        = "${var.project_name}-${var.environment}-emr-slave-sg"
  description = "Security group for EMR slave nodes"
  vpc_id      = var.vpc_id

  tags = {
    Name        = "${var.project_name}-${var.environment}-emr-slave-sg"
    Environment = var.environment
  }
}

# EMR Service Access Security Group
resource "aws_security_group" "emr_service_access" {
  name        = "${var.project_name}-${var.environment}-emr-service-sg"
  description = "Security group for EMR service access"
  vpc_id      = var.vpc_id

  tags = {
    Name        = "${var.project_name}-${var.environment}-emr-service-sg"
    Environment = var.environment
  }
}

# Master Security Group Rules
resource "aws_security_group_rule" "master_ingress_from_slave" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = aws_security_group.emr_slave.id
  security_group_id        = aws_security_group.emr_master.id
  description              = "Allow all from slave nodes"
}

resource "aws_security_group_rule" "master_ingress_from_service" {
  type                     = "ingress"
  from_port                = 8443
  to_port                  = 8443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.emr_service_access.id
  security_group_id        = aws_security_group.emr_master.id
  description              = "Allow HTTPS from service access"
}

resource "aws_security_group_rule" "master_egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.emr_master.id
  description       = "Allow all outbound"
}

# Slave Security Group Rules
resource "aws_security_group_rule" "slave_ingress_from_master" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = aws_security_group.emr_master.id
  security_group_id        = aws_security_group.emr_slave.id
  description              = "Allow all from master"
}

resource "aws_security_group_rule" "slave_ingress_from_self" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  self              = true
  security_group_id = aws_security_group.emr_slave.id
  description       = "Allow all from other slaves"
}

resource "aws_security_group_rule" "slave_ingress_from_service" {
  type                     = "ingress"
  from_port                = 8443
  to_port                  = 8443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.emr_service_access.id
  security_group_id        = aws_security_group.emr_slave.id
  description              = "Allow HTTPS from service access"
}

resource "aws_security_group_rule" "slave_egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.emr_slave.id
  description       = "Allow all outbound"
}

# Service Access Security Group Rules
resource "aws_security_group_rule" "service_egress_to_master" {
  type                     = "egress"
  from_port                = 8443
  to_port                  = 8443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.emr_master.id
  security_group_id        = aws_security_group.emr_service_access.id
  description              = "Allow HTTPS to master"
}

resource "aws_security_group_rule" "service_egress_to_slave" {
  type                     = "egress"
  from_port                = 8443
  to_port                  = 8443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.emr_slave.id
  security_group_id        = aws_security_group.emr_service_access.id
  description              = "Allow HTTPS to slaves"
}
