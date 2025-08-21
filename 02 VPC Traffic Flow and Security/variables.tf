variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  default     = "10.1.0.0/16"
}

variable "tags" {
  description = "A map of tags to assign to the VPC"
  type        = map(string)
  default = {
    Name        = "nextwork_iac"
    Environment = "development"
  }
}

variable "subnet_cidr" {
  description = "The CIDR block for the public subnet"
  default     = "10.1.1.0/24"
}

