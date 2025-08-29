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

# VPC A Configuration
variable "vpc_a_cidr" {
  description = "CIDR block for VPC A"
  type        = string
  default     = "10.1.0.0/16"
}

variable "vpc_a_name" {
  description = "Name for VPC A"
  type        = string
  default     = "nextwork-vpc-a"
}

variable "vpc_a_subnets" {
  description = "Subnet CIDRs for VPC A [public, private]"
  type        = list(string)
  default     = ["10.1.1.0/24", "10.1.2.0/24"]
}

# VPC B Configuration  
variable "vpc_b_cidr" {
  description = "CIDR block for VPC B"
  type        = string
  default     = "10.2.0.0/16"
}

variable "vpc_b_name" {
  description = "Name for VPC B"
  type        = string
  default     = "nextwork-vpc-b"
}

variable "vpc_b_subnets" {
  description = "Subnet CIDRs for VPC B [public, private]"
  type        = list(string)
  default     = ["10.2.1.0/24", "10.2.2.0/24"]
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

