variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-1"
}

variable "profile" {
  description = "AWS profile to use"
  type        = string
  default     = "afreetrade"
}

variable "common_tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default = {
    Project     = "nextwork-vpc-practice"
    Environment = "development"
  }
}

variable "vpc_cidr" {
  description = "CIDR block for VPC A"
  type        = string
  default     = "10.0.0.0/16"
}

variable "vpc_name" {
  description = "Name for VPC A"
  type        = string
  default     = "nextwork-vpc"
}

variable "vpc_subnet" {
  description = "Subnet CIDRs for VPC A [public, private]"
  type        = string
  default     = "10.0.1.0/24"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "s3_bucket_name" {
  description = "Name of the S3 bucket to create"
  type        = string
  default     = "nextwork-vpc-s3-demo-bucket"
}
