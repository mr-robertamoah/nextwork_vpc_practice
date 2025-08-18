# create vpc
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  tags                 = var.tags
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags_all             = var.tags
}

# create public subnet
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.subnet_cidr
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = merge(var.tags, {
    Name = "public-subnet"
  })
}

# create internet gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
  tags = merge(var.tags, {
    Name = "internet-gateway"
  })
}

# associate igw with default route table
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_vpc.main.default_route_table_id
}
