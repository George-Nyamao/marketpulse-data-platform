output "cluster_id" {
  description = "EMR cluster ID"
  value       = aws_emr_cluster.main.id
}

output "cluster_name" {
  description = "EMR cluster name"
  value       = aws_emr_cluster.main.name
}

output "master_public_dns" {
  description = "Master node public DNS"
  value       = aws_emr_cluster.main.master_public_dns
}

output "master_security_group_id" {
  description = "Master security group ID"
  value       = aws_security_group.emr_master.id
}

output "slave_security_group_id" {
  description = "Slave security group ID"
  value       = aws_security_group.emr_slave.id
}

output "service_access_security_group_id" {
  description = "Service access security group ID"
  value       = aws_security_group.emr_service_access.id
}
