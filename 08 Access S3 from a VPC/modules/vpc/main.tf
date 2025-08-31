# Create VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(var.tags, {
    Name = var.vpc_name
  })
}

# Create Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = merge(var.tags, {
    Name = "${var.vpc_name}-igw"
  })
}

# Create public subnet
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.subnet_cidr
  availability_zone       = data.aws_availability_zones.available.names[var.availability_zone_index]
  map_public_ip_on_launch = true

  tags = merge(var.tags, {
    Name = "${var.vpc_name}-public-subnet"
    Type = "public"
  })
}

# Create public and private route tables
resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.main.id

  tags = merge(var.tags, {
    Name = "${var.vpc_name}-public-rt"
    Type = "public"
  })
}

# Associate public subnet with public route table
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.rt.id
}

# Create a route in public rt using the igw
resource "aws_route" "public" {
  route_table_id         = aws_route_table.rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gw.id
}
