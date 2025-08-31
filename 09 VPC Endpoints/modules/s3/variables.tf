variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
}

variable "vpc_name" {
  description = "Name of the VPC (used for tagging and content)"
  type        = string
}

variable "tags" {
  description = "Tags to apply to S3 resources"
  type        = map(string)
  default     = {}
}

variable "vpc_endpoint_id" {
  description = "ID of the VPC endpoint for S3"
  type        = string
}
