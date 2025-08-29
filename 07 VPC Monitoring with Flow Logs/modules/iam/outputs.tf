output "flow_log_role_arn" {
  description = "ARN of the IAM role for VPC Flow Logs"
  value       = aws_iam_role.flow_log_role.arn
}

output "flow_log_role_name" {
  description = "Name of the IAM role for VPC Flow Logs"
  value       = aws_iam_role.flow_log_role.name
}
