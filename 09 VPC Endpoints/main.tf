# VPC A - Full VPC with public/private subnets, security, and compute
module "vpc" {
  source = "./modules/vpc"

  vpc_cidr                = var.vpc_cidr
  vpc_name                = var.vpc_name
  subnet_cidr             = var.vpc_subnet
  availability_zone_index = 0
  tags                    = var.common_tags
}

# S3 bucket for demonstration
module "s3" {
  source = "./modules/s3"

  bucket_name     = "${var.s3_bucket_name}-${random_string.bucket_suffix.result}"
  vpc_name        = var.vpc_name
  vpc_endpoint_id = module.vpc.s3_vpc_endpoint_id
  tags            = var.common_tags
}

# Random string for unique bucket naming
resource "random_string" "bucket_suffix" {
  length  = 8
  lower   = true
  upper   = false
  special = false
}

# IAM role and policies for S3 access
module "iam" {
  source = "./modules/iam"

  vpc_name   = var.vpc_name
  bucket_arn = module.s3.bucket_arn
  tags       = var.common_tags
}

module "security" {
  source = "./modules/security"

  vpc_id           = module.vpc.vpc_id
  vpc_cidr         = module.vpc.vpc_cidr_block
  vpc_name         = var.vpc_name
  public_subnet_id = module.vpc.public_subnet_id
  tags             = var.common_tags
}

module "compute" {
  source = "./modules/compute"

  vpc_name                 = var.vpc_name
  instance_type            = var.instance_type
  public_subnet_id         = module.vpc.public_subnet_id
  public_security_group_id = module.security.public_security_group_id
  iam_instance_profile     = module.iam.instance_profile_name
  bucket_name              = module.s3.bucket_name
  tags                     = var.common_tags
}
