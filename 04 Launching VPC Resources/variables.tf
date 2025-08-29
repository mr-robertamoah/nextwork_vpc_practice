variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  default     = "10.2.0.0/16"
}

variable "tags" {
  description = "A map of tags to assign to the VPC"
  type        = map(string)
  default = {
    Name        = "nextwork_iac"
    Environment = "development"
  }
}

variable "subnet_cidrs" {
  description = "The CIDR block for the public subnet"
  type        = list(string)
  default     = ["10.2.1.0/24", "10.2.2.0/24"]
}

variable "instance_type" {
  description = "The instance type for the EC2 instance"
  default     = "t2.micro"
}

variable "profile" {
  description = "The AWS profile to use"
  default     = "afreetrade"
}

variable "region" {
  description = "The AWS region to use"
  default     = "eu-west-1"
}

