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
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 80
  to_port        = 80
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

# Create security group for public instances
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

  tags = merge(var.tags, {
    Name = "${var.vpc_name}-public-sg"
  })
}
