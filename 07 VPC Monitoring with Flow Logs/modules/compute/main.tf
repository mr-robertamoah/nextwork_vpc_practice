# Create EC2 instance in public subnet
resource "aws_instance" "public" {
  ami                         = data.aws_ami.latest.id
  instance_type               = var.instance_type
  subnet_id                   = var.public_subnet_id
  security_groups             = [var.public_security_group_id]
  associate_public_ip_address = true

  tags = merge(var.tags, {
    Name = "${var.vpc_name}-public-ec2"
  })
}

# Create EC2 instance in private subnet
resource "aws_instance" "private" {
  ami             = data.aws_ami.latest.id
  instance_type   = var.instance_type
  subnet_id       = var.private_subnet_id
  security_groups = [var.private_security_group_id]

  tags = merge(var.tags, {
    Name = "${var.vpc_name}-private-ec2"
  })
}
