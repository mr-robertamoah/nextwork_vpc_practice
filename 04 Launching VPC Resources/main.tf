# create vpc
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  tags                 = var.tags
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags_all             = var.tags
}

# create public and private subnets
resource "aws_subnet" "subnets" {
  count                   = length(var.subnet_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.subnet_cidrs[count.index]
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = merge(var.tags, {
    Name = count.index == 0 ? "public-subnet" : "private-subnet"
  })
}

# create internet gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
  tags = merge(var.tags, {
    Name = "internet-gateway"
  })
}

# create public and private route tables
resource "aws_route_table" "rt" {
  count  = length(aws_subnet.subnets)
  vpc_id = aws_vpc.main.id

  tags = merge(var.tags, {
    Name = count.index == 0 ? "public-route-table" : "private-route-table"
  })
}

# associate public subnet with public route table
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.subnets[0].id
  route_table_id = aws_route_table.rt[0].id
}

# associate private subnet with private route table
resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.subnets[1].id
  route_table_id = aws_route_table.rt[1].id
}

# create a route in public rt using the igw
resource "aws_route" "public" {
  route_table_id         = aws_route_table.rt[0].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gw.id
}

# create NACL for public subnet
resource "aws_network_acl" "public_subnet_nacl" {
  vpc_id = aws_vpc.main.id

  tags = merge(var.tags, {
    Name = "public-nacl"
  })
}

# inbound rules for the public subnet
resource "aws_network_acl_rule" "subnet_nacl_ingress_http" {
  network_acl_id = aws_network_acl.public_subnet_nacl.id
  rule_number    = 100
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 80
  to_port        = 80
}

resource "aws_network_acl_rule" "subnet_nacl_ingress_https" {
  network_acl_id = aws_network_acl.public_subnet_nacl.id
  rule_number    = 110
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 443
  to_port        = 443
}

resource "aws_network_acl_rule" "subnet_nacl_ingress_ssh" {
  network_acl_id = aws_network_acl.public_subnet_nacl.id
  rule_number    = 120
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 22
  to_port        = 22
}

# ICMP rules for public subnet (to allow ping to external sites)
resource "aws_network_acl_rule" "public_subnet_nacl_ingress_icmp" {
  network_acl_id = aws_network_acl.public_subnet_nacl.id
  rule_number    = 130
  egress         = false
  protocol       = "icmp"
  icmp_type      = 0
  icmp_code      = -1
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
}

# outbound rules for the public subnet to all traffic and ports
resource "aws_network_acl_rule" "subnet_nacl_egress" {
  network_acl_id = aws_network_acl.public_subnet_nacl.id
  rule_number    = 100
  egress         = true
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
}

# associate public nacl to public subnet
resource "aws_network_acl_association" "public_subnet" {
  subnet_id      = aws_subnet.subnets[0].id
  network_acl_id = aws_network_acl.public_subnet_nacl.id
}

# create NACL for private subnet
resource "aws_network_acl" "private_subnet_nacl" {
  vpc_id = aws_vpc.main.id

  tags = merge(var.tags, {
    Name = "private-nacl"
  })
}

# associate private nacl to private subnet
resource "aws_network_acl_association" "private_subnet" {
  subnet_id      = aws_subnet.subnets[1].id
  network_acl_id = aws_network_acl.private_subnet_nacl.id
}

# inbound rules for the private subnet
resource "aws_network_acl_rule" "private_subnet_nacl_ingress_icmp" {
  network_acl_id = aws_network_acl.private_subnet_nacl.id
  rule_number    = 100
  egress         = false
  protocol       = "icmp"
  icmp_type      = 8
  icmp_code      = -1
  rule_action    = "allow"
  cidr_block     = var.vpc_cidr
}

# Additional inbound rule to allow ICMP Echo Reply (type 0) from VPC
resource "aws_network_acl_rule" "private_subnet_nacl_ingress_icmp_reply" {
  network_acl_id = aws_network_acl.private_subnet_nacl.id
  rule_number    = 110
  egress         = false
  protocol       = "icmp"
  icmp_type      = 0
  icmp_code      = -1
  rule_action    = "allow"
  cidr_block     = var.vpc_cidr
}

# outbound rules for the private subnet
resource "aws_network_acl_rule" "private_subnet_nacl_egress_icmp" {
  network_acl_id = aws_network_acl.private_subnet_nacl.id
  rule_number    = 100
  egress         = true
  protocol       = "icmp"
  icmp_type      = 0
  icmp_code      = -1
  rule_action    = "allow"
  cidr_block     = var.vpc_cidr
}

# outbound ICMP Echo Request (type 8) for private subnet
resource "aws_network_acl_rule" "private_subnet_nacl_egress_icmp_request" {
  network_acl_id = aws_network_acl.private_subnet_nacl.id
  rule_number    = 110
  egress         = true
  protocol       = "icmp"
  icmp_type      = 8
  icmp_code      = -1
  rule_action    = "allow"
  cidr_block     = var.vpc_cidr
}

# create security group for public subnet
resource "aws_security_group" "public_sg" {
  vpc_id = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow ICMP (ping) outbound - for pinging external sites and private instances
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "public-sg"
  })
}

# create security group for private subnet
resource "aws_security_group" "private_sg" {
  vpc_id = aws_vpc.main.id

  # Allow ICMP from VPC CIDR (includes public subnet)
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [var.vpc_cidr]
  }

  # Allow ICMP egress to VPC CIDR
  egress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [var.vpc_cidr]
  }

  tags = merge(var.tags, {
    Name = "private-sg"
  })
}

# create EC2 instance in public subnet
resource "aws_instance" "public" {
  ami                         = data.aws_ami.latest.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.subnets[0].id
  security_groups             = [aws_security_group.public_sg.id]
  associate_public_ip_address = true

  tags = merge(var.tags, {
    Name = "public-ec2"
  })
}

# create EC2 instance in private subnet
resource "aws_instance" "private" {
  ami                         = data.aws_ami.latest.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.subnets[1].id
  security_groups             = [aws_security_group.private_sg.id]
  associate_public_ip_address = false

  tags = merge(var.tags, {
    Name = "private-ec2"
  })
}
