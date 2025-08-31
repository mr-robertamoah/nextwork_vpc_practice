# S3 Bucket for VPC access demonstration
resource "aws_s3_bucket" "main" {
  bucket        = var.bucket_name
  force_destroy = true  # Allow Terraform to delete bucket with objects
  tags          = var.tags
}

# S3 Bucket versioning
resource "aws_s3_bucket_versioning" "main" {
  bucket = aws_s3_bucket.main.id
  versioning_configuration {
    status = "Enabled"
  }
}

# S3 Bucket server-side encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "main" {
  bucket = aws_s3_bucket.main.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# S3 Bucket public access block (secure by default)
resource "aws_s3_bucket_public_access_block" "main" {
  bucket = aws_s3_bucket.main.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Upload an image from my downloads
# Upload sample objects to the bucket
resource "aws_s3_object" "nextwork_denzel_image" {
  bucket = aws_s3_bucket.main.id
  key    = "nextwork-denzel-awesome.png"
  source = "${path.module}/assets/NextWork - Denzel is awesome.png"
  acl    = "private"
  
  etag = filemd5("${path.module}/assets/NextWork - Denzel is awesome.png")
}

resource "aws_s3_object" "nextwork_lelo_image" {
  bucket = aws_s3_bucket.main.id
  key    = "nextwork-lelo-awesome.png"
  source = "${path.module}/assets/NextWork - Lelo is awesome.png"
  acl    = "private"
  
  etag = filemd5("${path.module}/assets/NextWork - Lelo is awesome.png")
}

# S3 Bucket Policy to restrict access to VPC Endpoint only
# Note: This is commented out to allow initial deployment
# Use the management scripts on EC2 to apply restrictive policies after deployment

# resource "aws_s3_bucket_policy" "vpc_endpoint_policy" {
#   bucket = aws_s3_bucket.main.id

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Sid       = "VPCEndpointAccessOnly"
#         Effect    = "Allow"
#         Principal = "*"
#         Action = [
#           "s3:GetObject",
#           "s3:PutObject",
#           "s3:ListBucket"
#         ]
#         Resource = [
#           aws_s3_bucket.main.arn,
#           "${aws_s3_bucket.main.arn}/*"
#         ]
#         Condition = {
#           StringEquals = {
#             "aws:sourceVpce" = var.vpc_endpoint_id
#           }
#         }
#       },
#       {
#         Sid       = "DenyNonVPCEndpointAccess"
#         Effect    = "Deny"
#         Principal = "*"
#         Action = [
#           "s3:GetObject",
#           "s3:PutObject",
#           "s3:DeleteObject"
#         ]
#         Resource = "${aws_s3_bucket.main.arn}/*"
#         Condition = {
#           StringNotEquals = {
#             "aws:sourceVpce" = var.vpc_endpoint_id
#           }
#         }
#       }
#     ]
#   })
# }

# Get current AWS account ID
data "aws_caller_identity" "current" {}
