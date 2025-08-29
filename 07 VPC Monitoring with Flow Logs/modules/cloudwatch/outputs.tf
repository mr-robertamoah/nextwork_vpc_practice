output "log_group_name" {
  description = "Name of the CloudWatch Log Group"
  value       = aws_cloudwatch_log_group.vpc_flow_log_group.name
}

output "log_group_arn" {
  description = "ARN of the CloudWatch Log Group"
  value       = aws_cloudwatch_log_group.vpc_flow_log_group.arn
}

output "log_stream_name" {
  description = "Name of the CloudWatch Log Stream"
  value       = aws_cloudwatch_log_stream.vpc_flow_log_stream.name
}
