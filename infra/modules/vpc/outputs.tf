output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_ids" {
  value = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  value = aws_subnet.private[*].id
}

output "s3_endpoint_id" {
  value = aws_vpc_endpoint.s3.id
}

output "glue_endpoint_id" {
  value = aws_vpc_endpoint.glue.id
}

output "logs_endpoint_id" {
  value = aws_vpc_endpoint.logs.id
}

output "sts_endpoint_id" {
  value = aws_vpc_endpoint.sts.id
}

output "ec2_endpoint_id" {
  value = aws_vpc_endpoint.ec2.id
}

output "kms_endpoint_id" {
  value = aws_vpc_endpoint.kms.id
}
# NAT Gateway
output "nat_gateway_id" {
  description = "NAT Gateway ID"
  value       = aws_nat_gateway.main.id
}

output "nat_eip_public_ip" {
  description = "NAT Gateway Elastic IP"
  value       = aws_eip.nat.public_ip
}
