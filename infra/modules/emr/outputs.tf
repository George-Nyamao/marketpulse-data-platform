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
  description = "EMR-managed master security group ID"
  value       = try(aws_emr_cluster.main.ec2_attributes[0].emr_managed_master_security_group, "")
}

output "slave_security_group_id" {
  description = "EMR-managed slave security group ID"  
  value       = try(aws_emr_cluster.main.ec2_attributes[0].emr_managed_slave_security_group, "")
}

output "service_access_security_group_id" {
  description = "EMR-managed service access security group ID"
  value       = try(aws_emr_cluster.main.ec2_attributes[0].service_access_security_group, "")
}

output "emr_managed_scaling_policy_id" {
  description = "EMR managed scaling policy ID"
  value       = aws_emr_managed_scaling_policy.main.id
}
