output "available_zones" {
  value = data.aws_availability_zones.available.names
}

output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_id" {
  value = aws_subnet.public.id
}

output "route_table_id" {
  value = aws_route_table.public.id
}

output "aws_internet_gateway_id" {
  value = aws_internet_gateway.gw.id
}

output "public_subnet_nacl_id" {
  value = aws_network_acl.public_subnet_nacl.id
}

output "security_group_public_subnet_id" {
  value = aws_security_group.public_subnet_sg.id
}