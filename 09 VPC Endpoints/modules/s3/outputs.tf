output "bucket_name" {
  description = "Name of the created S3 bucket"
  value       = aws_s3_bucket.main.bucket
}

output "bucket_arn" {
  description = "ARN of the created S3 bucket"
  value       = aws_s3_bucket.main.arn
}

output "bucket_id" {
  description = "ID of the created S3 bucket"
  value       = aws_s3_bucket.main.id
}

output "bucket_domain_name" {
  description = "Domain name of the S3 bucket"
  value       = aws_s3_bucket.main.bucket_domain_name
}

output "uploaded_images" {
  description = "List of uploaded images in the bucket"
  value = {
    nextwork_denzel_image = aws_s3_object.nextwork_denzel_image.key
    nextwork_lelo_image = aws_s3_object.nextwork_lelo_image.key
  }
}
