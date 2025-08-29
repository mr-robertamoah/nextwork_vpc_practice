# CloudWatch Log Group for VPC Flow Logs
resource "aws_cloudwatch_log_group" "vpc_flow_log_group" {
  name              = "/aws/vpc/flowlogs/${var.vpc_name}"
  retention_in_days = var.log_retention_days

  tags = merge(var.tags, {
    Name = "${var.vpc_name}-flow-logs"
    Purpose = "VPC Flow Logs storage"
  })
}

# CloudWatch Log Stream for VPC Flow Logs
resource "aws_cloudwatch_log_stream" "vpc_flow_log_stream" {
  name           = "${var.vpc_name}-flow-log-stream"
  log_group_name = aws_cloudwatch_log_group.vpc_flow_log_group.name
}
