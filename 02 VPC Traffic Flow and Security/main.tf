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

# create route table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = merge(var.tags, {
    Name = "public-route-table"
  })
}

# associate igw with default route table
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# create NACL for public subnet
resource "aws_network_acl" "public_subnet_nacl" {
  vpc_id = aws_vpc.main.id

  tags = merge(var.tags, {
    Name = "public-nacl"
  })
}

# inbound rules for the public subnet
resource "aws_network_acl_rule" "public_subnet_nacl_ingress_http" {
  network_acl_id = aws_network_acl.public_subnet_nacl.id
  rule_number    = 100
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 80
  to_port        = 80
}

resource "aws_network_acl_rule" "public_subnet_nacl_ingress_https" {
  network_acl_id = aws_network_acl.public_subnet_nacl.id
  rule_number    = 100
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 443
  to_port        = 443
}

# outbound rules for the public subnet
resource "aws_network_acl_rule" "public_subnet_nacl_egress" {
  network_acl_id = aws_network_acl.public_subnet_nacl.id
  rule_number    = 200
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = -1
  to_port        = -1
}

# associate public nacl to public subnet
resource "aws_network_acl_association" "public_subnet" {
  subnet_id     = aws_subnet.public.id
  network_acl_id = aws_network_acl.public_subnet_nacl.id
}

# create security group for public subnet
resource "aws_security_group" "public_subnet_sg" {
  vpc_id = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "public-sg"
  })
}
