# VPC A - Full VPC with public/private subnets, security, and compute
module "vpc_a" {
  source = "./modules/vpc"

  vpc_cidr                = var.vpc_a_cidr
  vpc_name                = var.vpc_a_name
  subnet_cidrs            = var.vpc_a_subnets
  availability_zone_index = 0
  tags                    = var.common_tags
}

module "security_a" {
  source = "./modules/security"

  vpc_id            = module.vpc_a.vpc_id
  vpc_cidr          = module.vpc_a.vpc_cidr_block
  peer_vpc_cidr     = module.vpc_b.vpc_cidr_block
  vpc_name          = var.vpc_a_name
  public_subnet_id  = module.vpc_a.public_subnet_id
  private_subnet_id = module.vpc_a.private_subnet_id
  tags              = var.common_tags
}

module "compute_a" {
  source = "./modules/compute"

  vpc_name                  = var.vpc_a_name
  instance_type             = var.instance_type
  public_subnet_id          = module.vpc_a.public_subnet_id
  private_subnet_id         = module.vpc_a.private_subnet_id
  public_security_group_id  = module.security_a.public_security_group_id
  private_security_group_id = module.security_a.private_security_group_id
  tags                      = var.common_tags
}

# VPC B - Full VPC with public/private subnets, security, and compute
module "vpc_b" {
  source = "./modules/vpc"

  vpc_cidr                = var.vpc_b_cidr
  vpc_name                = var.vpc_b_name
  subnet_cidrs            = var.vpc_b_subnets
  availability_zone_index = 0
  tags                    = var.common_tags
}

module "security_b" {
  source = "./modules/security"

  vpc_id            = module.vpc_b.vpc_id
  vpc_cidr          = module.vpc_b.vpc_cidr_block
  peer_vpc_cidr     = module.vpc_a.vpc_cidr_block
  vpc_name          = var.vpc_b_name
  public_subnet_id  = module.vpc_b.public_subnet_id
  private_subnet_id = module.vpc_b.private_subnet_id
  tags              = var.common_tags
}

module "compute_b" {
  source = "./modules/compute"

  vpc_name                  = var.vpc_b_name
  instance_type             = var.instance_type
  public_subnet_id          = module.vpc_b.public_subnet_id
  private_subnet_id         = module.vpc_b.private_subnet_id
  public_security_group_id  = module.security_b.public_security_group_id
  private_security_group_id = module.security_b.private_security_group_id
  tags                      = var.common_tags
}

# VPC Peering Connection
resource "aws_vpc_peering_connection" "peer" {
  peer_vpc_id = module.vpc_b.vpc_id
  vpc_id      = module.vpc_a.vpc_id
  auto_accept = true

  tags = merge(var.common_tags, {
    Name = "${var.vpc_a_name}-to-${var.vpc_b_name}-peering"
  })
}

# Add routes for peering in VPC A route tables
resource "aws_route" "vpc_a_public_to_vpc_b" {
  route_table_id            = module.vpc_a.public_route_table_id
  destination_cidr_block    = var.vpc_b_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
}

resource "aws_route" "vpc_a_private_to_vpc_b" {
  route_table_id            = module.vpc_a.private_route_table_id
  destination_cidr_block    = var.vpc_b_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
}

# Add routes for peering in VPC B route tables  
resource "aws_route" "vpc_b_public_to_vpc_a" {
  route_table_id            = module.vpc_b.public_route_table_id
  destination_cidr_block    = var.vpc_a_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
}

resource "aws_route" "vpc_b_private_to_vpc_a" {
  route_table_id            = module.vpc_b.private_route_table_id
  destination_cidr_block    = var.vpc_a_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
}
