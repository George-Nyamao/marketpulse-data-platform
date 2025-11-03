variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "emr_release" {
  description = "EMR release version"
  type        = string
  default     = "emr-6.15.0"
}

variable "subnet_ids" {
  description = "List of subnet IDs for EMR cluster"
  type        = list(string)
}

variable "emr_service_role_name" {
  description = "EMR service role name"
  type        = string
}

variable "emr_ec2_instance_profile_name" {
  description = "EMR EC2 instance profile name"
  type        = string
}

variable "logs_bucket" {
  description = "S3 bucket for EMR logs"
  type        = string
}

variable "master_instance_type" {
  description = "Master node instance type"
  type        = string
  default     = "m5.xlarge"
}

variable "core_instance_type" {
  description = "Core node instance type"
  type        = string
  default     = "m5.xlarge"
}

variable "core_instance_count" {
  description = "Number of core nodes"
  type        = number
  default     = 2
}

variable "key_name" {
  description = "EC2 key pair name (optional)"
  type        = string
  default     = null
}

variable "auto_termination_idle_timeout" {
  description = "Auto-termination idle timeout in seconds"
  type        = number
  default     = 1800
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}
