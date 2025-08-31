output "iam_role_name" {
  description = "Name of the IAM role"
  value       = aws_iam_role.ec2_s3_role.name
}

output "iam_role_arn" {
  description = "ARN of the IAM role"
  value       = aws_iam_role.ec2_s3_role.arn
}

output "instance_profile_name" {
  description = "Name of the IAM instance profile"
  value       = aws_iam_instance_profile.ec2_s3_profile.name
}

output "instance_profile_arn" {
  description = "ARN of the IAM instance profile"
  value       = aws_iam_instance_profile.ec2_s3_profile.arn
}

output "s3_list_policy_arn" {
  description = "ARN of the S3 list buckets policy"
  value       = aws_iam_policy.s3_list_buckets.arn
}

output "s3_bucket_policy_arn" {
  description = "ARN of the S3 bucket full access policy"
  value       = aws_iam_policy.s3_bucket_full_access.arn
}
