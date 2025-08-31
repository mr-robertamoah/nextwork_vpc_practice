variable "vpc_name" {
  description = "Name of the VPC (used for resource naming)"
  type        = string
}

variable "bucket_arn" {
  description = "ARN of the S3 bucket to grant access to"
  type        = string
}

variable "tags" {
  description = "Tags to apply to IAM resources"
  type        = map(string)
  default     = {}
}
