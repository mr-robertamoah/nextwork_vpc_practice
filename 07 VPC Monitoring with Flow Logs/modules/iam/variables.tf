variable "name_prefix" {
  description = "Name prefix for IAM resources"
  type        = string
}

variable "tags" {
  description = "A map of tags to assign to resources"
  type        = map(string)
  default     = {}
}
