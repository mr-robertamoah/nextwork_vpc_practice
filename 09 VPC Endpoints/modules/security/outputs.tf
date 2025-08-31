output "public_nacl_id" {
  description = "ID of the public subnet NACL"
  value       = aws_network_acl.public_subnet_nacl.id
}

output "public_security_group_id" {
  description = "ID of the public security group"
  value       = aws_security_group.public_sg.id
}
