# IAM Role for VPC Flow Logs
resource "aws_iam_role" "flow_log_role" {
  name_prefix = "${var.name_prefix}-flow-log-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "vpc-flow-logs.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-flow-log-role"
    Purpose = "VPC Flow Logs CloudWatch delivery"
  })
}

# IAM Policy for CloudWatch Logs permissions
resource "aws_iam_policy" "flow_log_policy" {
  name_prefix = "${var.name_prefix}-flow-log-policy"
  description = "Policy for VPC Flow Logs to write to CloudWatch"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ]
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-flow-log-policy"
  })
}

# Attach the policy to the role
resource "aws_iam_role_policy_attachment" "flow_log_policy_attachment" {
  role       = aws_iam_role.flow_log_role.name
  policy_arn = aws_iam_policy.flow_log_policy.arn
}
