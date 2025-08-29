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

# Create public and private subnets
resource "aws_subnet" "subnets" {
  count                   = length(var.subnet_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.subnet_cidrs[count.index]
  availability_zone       = data.aws_availability_zones.available.names[var.availability_zone_index]
  map_public_ip_on_launch = count.index == 0 ? true : false

  tags = merge(var.tags, {
    Name = count.index == 0 ? "${var.vpc_name}-public-subnet" : "${var.vpc_name}-private-subnet"
    Type = count.index == 0 ? "public" : "private"
  })
}

# Create public and private route tables
resource "aws_route_table" "rt" {
  count  = length(aws_subnet.subnets)
  vpc_id = aws_vpc.main.id

  tags = merge(var.tags, {
    Name = count.index == 0 ? "${var.vpc_name}-public-rt" : "${var.vpc_name}-private-rt"
    Type = count.index == 0 ? "public" : "private"
  })
}

# Associate public subnet with public route table
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.subnets[0].id
  route_table_id = aws_route_table.rt[0].id
}

# Associate private subnet with private route table
resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.subnets[1].id
  route_table_id = aws_route_table.rt[1].id
}

# Create a route in public rt using the igw
resource "aws_route" "public" {
  route_table_id         = aws_route_table.rt[0].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gw.id
}

# VPC Flow Logs for public subnet
resource "aws_flow_log" "public_subnet_flow_log" {
  count                = var.enable_flow_logs ? 1 : 0
  iam_role_arn         = var.flow_log_role_arn
  log_destination      = var.log_group_arn
  log_destination_type = "cloud-watch-logs"
  subnet_id            = aws_subnet.subnets[0].id
  traffic_type         = var.flow_log_traffic_type

  tags = merge(var.tags, {
    Name = "${var.vpc_name}-public-subnet-flow-log"
    Purpose = "Public subnet traffic monitoring"
  })
}
