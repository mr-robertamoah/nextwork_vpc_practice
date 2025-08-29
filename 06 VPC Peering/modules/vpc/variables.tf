variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
}

variable "vpc_name" {
  description = "Name for the VPC"
  type        = string
}

variable "subnet_cidrs" {
  description = "List of CIDR blocks for subnets [public, private]"
  type        = list(string)
  validation {
    condition     = length(var.subnet_cidrs) == 2
    error_message = "Exactly 2 subnet CIDRs must be provided: [public, private]."
  }
}

variable "availability_zone_index" {
  description = "Index to select availability zone from available zones"
  type        = number
  default     = 0
}

variable "tags" {
  description = "A map of tags to assign to resources"
  type        = map(string)
  default     = {}
}
