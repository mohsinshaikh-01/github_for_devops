variable "bucket_name" {
  description = "S3 bucket name"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "enable_versioning" {
  description = "Set true to enable versioning Or false"
  type        = bool
  default     = false
}

variable "enable_lifecycle" {
  description = "Set tru to enable lifecycle or false"
  type        = bool
  default     = false 
}

variable "enable_kms_encryption" {
  description = "Set to true to enable encryption or false"
  type        = bool
  default     = false
}

variable "enable_cors" {
  description = "Set to true to enable CORS or false"
  type        = bool
  default     = false
}

variable "enable_object_lock" {
  description = "Set to true to enable S3 Object Lock in Governance mode"
  type        = bool
  default     = false
}

variable "enable_access_log" {
  description = "Set to true to enable access logs on the bucket."
  type        = bool
  default     = false
}

variable "central_log_bucket_name" {
  description = "The exact name of the existing S3 bucket where all access logs should be delivered."
  type        = string
}