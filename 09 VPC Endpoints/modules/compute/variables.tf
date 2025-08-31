variable "vpc_name" {
  description = "Name prefix for EC2 instances"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "public_subnet_id" {
  description = "ID of the public subnet"
  type        = string
}

variable "public_security_group_id" {
  description = "ID of the public security group"
  type        = string
}

variable "tags" {
  description = "A map of tags to assign to resources"
  type        = map(string)
  default     = {}
}

variable "iam_instance_profile" {
  description = "Name of the IAM instance profile to attach to EC2 instances"
  type        = string
  default     = null
}

variable "bucket_name" {
  description = "Name of the S3 bucket for testing access"
  type        = string
}
