# S3 Bucket for VPC access demonstration
resource "aws_s3_bucket" "main" {
  bucket = var.bucket_name
  tags   = var.tags
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
