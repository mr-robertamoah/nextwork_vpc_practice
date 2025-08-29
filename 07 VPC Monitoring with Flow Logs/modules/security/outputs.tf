output "public_nacl_id" {
  description = "ID of the public subnet NACL"
  value       = aws_network_acl.public_subnet_nacl.id
}

output "private_nacl_id" {
  description = "ID of the private subnet NACL"
  value       = aws_network_acl.private_subnet_nacl.id
}

output "public_security_group_id" {
  description = "ID of the public security group"
  value       = aws_security_group.public_sg.id
}

output "private_security_group_id" {
  description = "ID of the private security group"
  value       = aws_security_group.private_sg.id
}
