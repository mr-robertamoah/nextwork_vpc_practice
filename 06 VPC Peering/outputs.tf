# VPC A Outputs
output "vpc_a_id" {
  description = "ID of VPC A"
  value       = module.vpc_a.vpc_id
}

output "vpc_a_public_instance_ip" {
  description = "Public IP of VPC A public instance"
  value       = module.compute_a.public_instance_ip
}

output "vpc_a_private_instance_ip" {
  description = "Private IP of VPC A private instance"
  value       = module.compute_a.private_instance_ip
}

# VPC B Outputs  
output "vpc_b_id" {
  description = "ID of VPC B"
  value       = module.vpc_b.vpc_id
}

output "vpc_b_public_instance_ip" {
  description = "Public IP of VPC B public instance"
  value       = module.compute_b.public_instance_ip
}

output "vpc_b_private_instance_ip" {
  description = "Private IP of VPC B private instance"
  value       = module.compute_b.private_instance_ip
}

# VPC Peering Outputs
output "peering_connection_id" {
  description = "ID of the VPC peering connection"
  value       = aws_vpc_peering_connection.peer.id
}

output "peering_connection_status" {
  description = "Status of the VPC peering connection"
  value       = aws_vpc_peering_connection.peer.accept_status
}

# Connection Information
output "connectivity_test_commands" {
  description = "Commands to test connectivity between VPCs"
  value = {
    "vpc_a_to_vpc_b_public"  = "ping ${module.compute_b.public_instance_private_ip}"
    "vpc_a_to_vpc_b_private" = "ping ${module.compute_b.private_instance_ip}"
    "vpc_b_to_vpc_a_public"  = "ping ${module.compute_a.public_instance_private_ip}"
    "vpc_b_to_vpc_a_private" = "ping ${module.compute_a.private_instance_ip}"
  }
}