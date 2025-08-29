# Create NACL for public subnet
resource "aws_network_acl" "public_subnet_nacl" {
  vpc_id = var.vpc_id

  tags = merge(var.tags, {
    Name = "${var.vpc_name}-public-nacl"
  })
}

# Public NACL Rules
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
  rule_number    = 110
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 443
  to_port        = 443
}

resource "aws_network_acl_rule" "public_subnet_nacl_ingress_ssh" {
  network_acl_id = aws_network_acl.public_subnet_nacl.id
  rule_number    = 120
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 22
  to_port        = 22
}

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

resource "aws_network_acl_rule" "public_subnet_nacl_egress" {
  network_acl_id = aws_network_acl.public_subnet_nacl.id
  rule_number    = 100
  egress         = true
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
}

# Associate public nacl to public subnet
resource "aws_network_acl_association" "public_subnet" {
  subnet_id      = var.public_subnet_id
  network_acl_id = aws_network_acl.public_subnet_nacl.id
}

# Create NACL for private subnet
resource "aws_network_acl" "private_subnet_nacl" {
  vpc_id = var.vpc_id

  tags = merge(var.tags, {
    Name = "${var.vpc_name}-private-nacl"
  })
}

# Private NACL Rules
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

resource "aws_network_acl_rule" "private_subnet_nacl_ingress_icmp_peer" {
  network_acl_id = aws_network_acl.private_subnet_nacl.id
  rule_number    = 101
  egress         = false
  protocol       = "icmp"
  icmp_type      = 8
  icmp_code      = -1
  rule_action    = "allow"
  cidr_block     = var.peer_vpc_cidr
}

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

resource "aws_network_acl_rule" "private_subnet_nacl_ingress_icmp_reply_peer" {
  network_acl_id = aws_network_acl.private_subnet_nacl.id
  rule_number    = 111
  egress         = false
  protocol       = "icmp"
  icmp_type      = 0
  icmp_code      = -1
  rule_action    = "allow"
  cidr_block     = var.peer_vpc_cidr
}

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

resource "aws_network_acl_rule" "private_subnet_nacl_egress_icmp_peer" {
  network_acl_id = aws_network_acl.private_subnet_nacl.id
  rule_number    = 101
  egress         = true
  protocol       = "icmp"
  icmp_type      = 0
  icmp_code      = -1
  rule_action    = "allow"
  cidr_block     = var.peer_vpc_cidr
}

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

resource "aws_network_acl_rule" "private_subnet_nacl_egress_icmp_request_peer" {
  network_acl_id = aws_network_acl.private_subnet_nacl.id
  rule_number    = 111
  egress         = true
  protocol       = "icmp"
  icmp_type      = 8
  icmp_code      = -1
  rule_action    = "allow"
  cidr_block     = var.peer_vpc_cidr
}

# Associate private nacl to private subnet
resource "aws_network_acl_association" "private_subnet" {
  subnet_id      = var.private_subnet_id
  network_acl_id = aws_network_acl.private_subnet_nacl.id
}

# Create security group for public subnet
resource "aws_security_group" "public_sg" {
  name_prefix = "${var.vpc_name}-public-sg"
  vpc_id      = var.vpc_id

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

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.vpc_name}-public-sg"
  })
}

# Create security group for private subnet
resource "aws_security_group" "private_sg" {
  name_prefix = "${var.vpc_name}-private-sg"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [var.vpc_cidr]
  }

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [var.peer_vpc_cidr]
  }

  egress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [var.peer_vpc_cidr]
  }

  tags = merge(var.tags, {
    Name = "${var.vpc_name}-private-sg"
  })
}
