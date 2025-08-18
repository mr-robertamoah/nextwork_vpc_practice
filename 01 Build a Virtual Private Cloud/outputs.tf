output "available_zones" {
  value = data.aws_availability_zones.available.names
}

output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_id" {
  value = aws_subnet.public.id
}

output "aws_internet_gateway_id" {
  value = aws_internet_gateway.gw.id
}