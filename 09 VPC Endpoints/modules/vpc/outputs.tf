output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = aws_internet_gateway.gw.id
}

output "public_subnet_id" {
  description = "ID of the public subnet"
  value       = aws_subnet.public_subnet.id
}

output "public_route_table_id" {
  description = "ID of the public route table"
  value       = aws_route_table.rt.id
}

output "availability_zone" {
  description = "The availability zone used for subnets"
  value       = data.aws_availability_zones.available.names[var.availability_zone_index]
}

output "s3_vpc_endpoint_id" {
  description = "ID of the S3 VPC Endpoint"
  value       = aws_vpc_endpoint.s3.id
}

output "s3_vpc_endpoint_prefix_list_id" {
  description = "Prefix list ID of the S3 VPC Endpoint for use in security group rules"
  value       = aws_vpc_endpoint.s3.prefix_list_id
}
