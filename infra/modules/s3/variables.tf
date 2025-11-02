variable "project_name" {
  description = "Project name for bucket naming"
  type        = string
}

variable "environment" {
  description = "Environment (dev/stg/prod)"
  type        = string
}

variable "bucket_suffix" {
  description = "Suffix for bucket uniqueness"
  type        = string
}

variable "enable_versioning" {
  description = "Enable versioning on buckets"
  type        = bool
  default     = true
}

variable "raw_lifecycle_days" {
  description = "Days before transitioning raw data to IA"
  type        = number
  default     = 90
}

variable "logs_retention_days" {
  description = "Days to retain logs before deletion"
  type        = number
  default     = 30
}

variable "raw_glacier_days" {
  description = "Days before transitioning raw data to Glacier Deep Archive"
  type        = number
  default     = 180
}

variable "artifacts_ia_days" {
  description = "Days before transitioning artifacts to Infrequent Access"
  type        = number
  default     = 90
}
