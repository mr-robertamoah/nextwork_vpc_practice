# VPC A Outputs
output "vpc_id" {
  description = "ID of VPC A"
  value       = module.vpc.vpc_id
}

output "vpc_public_instance_ip" {
  description = "Public IP of VPC A public instance"
  value       = module.compute.public_instance_ip
}

# S3 Outputs
output "s3_bucket_name" {
  description = "Name of the created S3 bucket"
  value       = module.s3.bucket_name
}

output "s3_bucket_arn" {
  description = "ARN of the created S3 bucket"
  value       = module.s3.bucket_arn
}

output "uploaded_images" {
  description = "List of uploaded images in the S3 bucket"
  value       = module.s3.uploaded_images
}

# VPC Endpoint Outputs
output "s3_vpc_endpoint_id" {
  description = "ID of the S3 VPC Endpoint"
  value       = module.vpc.s3_vpc_endpoint_id
}

output "s3_vpc_endpoint_prefix_list_id" {
  description = "Prefix list ID of the S3 VPC Endpoint"
  value       = module.vpc.s3_vpc_endpoint_prefix_list_id
}

# IAM Outputs
output "iam_role_name" {
  description = "Name of the IAM role for S3 access"
  value       = module.iam.iam_role_name
}

output "instance_profile_name" {
  description = "Name of the IAM instance profile"
  value       = module.iam.instance_profile_name
}

# Connection Instructions
output "connection_instructions" {
  description = "Instructions for connecting and testing S3 access"
  value       = <<-EOT
    
    === S3 VPC Endpoint Access Test Instructions ===
    
    1. Connect to the EC2 instance using EC2 connect
    
    2. Run the S3 access test script:
       ./test-s3-access.sh
    
    3. Manual AWS CLI commands to test:
       aws s3 ls                                         # List all buckets
       aws s3 ls s3://${module.s3.bucket_name}           # List bucket contents
       aws s3 cp s3://${module.s3.bucket_name}/nextwork-denzel-awesome.png /tmp/  # Download Denzel image
       aws s3 cp s3://${module.s3.bucket_name}/nextwork-lelo-awesome.png /tmp/    # Download Lelo image
    
    Bucket Name: ${module.s3.bucket_name}
    IAM Role: ${module.iam.iam_role_name}
    VPC Endpoint: ${module.vpc.s3_vpc_endpoint_id}
    
    ⚠️ IMPORTANT: This bucket is configured with VPC Endpoint access only!
    S3 access from outside the VPC (internet) will be denied.
    All requests must route through the VPC Endpoint for security.
    
  EOT
}