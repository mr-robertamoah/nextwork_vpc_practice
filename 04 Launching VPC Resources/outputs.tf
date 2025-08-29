output "available_zones" {
  value = data.aws_availability_zones.available.names
}

output "vpc_id" {
  value = aws_vpc.main.id
}

output "subnet_id" {
  value = aws_subnet.subnets[*].id
}

output "route_table_ids" {
  value = aws_route_table.rt[*].id
}

output "aws_internet_gateway_id" {
  value = aws_internet_gateway.gw.id
}

output "public_subnet_nacl_id" {
  value = aws_network_acl.public_subnet_nacl.id
}

output "security_group_public_subnet_id" {
  value = aws_security_group.public_sg.id
}

output "ec2_public_instance_id" {
  value = aws_instance.public.id
}

output "ec2_public_instance_private_ip" {
  value = aws_instance.public.private_ip
}

output "ec2_public_instance_public_ip" {
  value = aws_instance.public.public_ip
}

output "ec2_private_instance_id" {
  value = aws_instance.private.id
}

output "ec2_private_instance_private_ip" {
  value = aws_instance.private.private_ip
}

output "ec2_private_instance_public_ip" {
  value = aws_instance.private.public_ip
}