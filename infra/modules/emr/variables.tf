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

# Managed Scaling Configuration
variable "managed_scaling_min" {
  description = "Minimum capacity for managed scaling"
  type        = number
  default     = 2
}

variable "managed_scaling_max" {
  description = "Maximum capacity for managed scaling"
  type        = number
  default     = 10
}

# Task Instance Fleet Configuration
variable "task_instance_count" {
  description = "Initial number of task instances (managed by scaling policy)"
  type        = number
  default     = 0  # Start with 0, scaling will add task nodes as needed
}

# Bootstrap Actions
variable "bootstrap_actions" {
  description = "List of bootstrap actions to run on cluster nodes"
  type = list(object({
    name = string
    path = string
    args = list(string)
  }))
  default = []
}

# CloudWatch Logging (optional)
variable "cloudwatch_log_group" {
  description = "CloudWatch log group name for EMR logs (optional)"
  type        = string
  default     = null
}

# KMS Key (optional, for log encryption)
variable "kms_key_id" {
  description = "KMS key ID for log encryption (optional)"
  type        = string
  default     = null
}
