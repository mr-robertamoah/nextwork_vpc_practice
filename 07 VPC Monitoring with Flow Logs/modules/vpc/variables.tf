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

# Flow Logs Configuration
variable "enable_flow_logs" {
  description = "Enable VPC Flow Logs for public subnets"
  type        = bool
  default     = false
}

variable "flow_log_role_arn" {
  description = "ARN of the IAM role for VPC Flow Logs"
  type        = string
  default     = ""
}

variable "log_group_arn" {
  description = "ARN of the CloudWatch Log Group"
  type        = string
  default     = ""
}

variable "flow_log_traffic_type" {
  description = "Type of traffic to log (ALL, ACCEPT, REJECT)"
  type        = string
  default     = "ALL"
  
  validation {
    condition     = contains(["ALL", "ACCEPT", "REJECT"], var.flow_log_traffic_type)
    error_message = "Traffic type must be ALL, ACCEPT, or REJECT."
  }
}
