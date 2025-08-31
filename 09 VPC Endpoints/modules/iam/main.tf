# IAM role for EC2 instances to access S3
resource "aws_iam_role" "ec2_s3_role" {
  name = "${var.vpc_name}-ec2-s3-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

# IAM policy for listing all S3 buckets
resource "aws_iam_policy" "s3_list_buckets" {
  name        = "${var.vpc_name}-s3-list-buckets"
  description = "Policy to allow listing all S3 buckets"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:ListAllMyBuckets",
          "s3:GetBucketLocation"
        ]
        Resource = "*"
      }
    ]
  })

  tags = var.tags
}

# IAM policy for full access to specific S3 bucket
resource "aws_iam_policy" "s3_bucket_full_access" {
  name        = "${var.vpc_name}-s3-bucket-access"
  description = "Policy for full access to specific S3 bucket"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:GetObjectVersion",
          "s3:DeleteObjectVersion",
          "s3:ListBucket",
          "s3:GetBucketVersioning",
          "s3:GetBucketLocation",
          "s3:GetBucketAcl"
        ]
        Resource = [
          var.bucket_arn,
          "${var.bucket_arn}/*"
        ]
      }
    ]
  })

  tags = var.tags
}

# IAM policy for managing bucket policies (for VPC endpoint testing)
resource "aws_iam_policy" "s3_bucket_policy_management" {
  name        = "${var.vpc_name}-s3-bucket-policy-management"
  description = "Policy to allow managing S3 bucket policies"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetBucketPolicy",
          "s3:PutBucketPolicy", 
          "s3:DeleteBucketPolicy"
        ]
        Resource = var.bucket_arn
      }
    ]
  })

  tags = var.tags
}

# Attach the policies to the role
resource "aws_iam_role_policy_attachment" "s3_list_buckets" {
  role       = aws_iam_role.ec2_s3_role.name
  policy_arn = aws_iam_policy.s3_list_buckets.arn
}

resource "aws_iam_role_policy_attachment" "s3_bucket_full_access" {
  role       = aws_iam_role.ec2_s3_role.name
  policy_arn = aws_iam_policy.s3_bucket_full_access.arn
}

resource "aws_iam_role_policy_attachment" "s3_bucket_policy_management" {
  role       = aws_iam_role.ec2_s3_role.name
  policy_arn = aws_iam_policy.s3_bucket_policy_management.arn
}

# Create instance profile
resource "aws_iam_instance_profile" "ec2_s3_profile" {
  name = "${var.vpc_name}-ec2-s3-profile"
  role = aws_iam_role.ec2_s3_role.name

  tags = var.tags
}
