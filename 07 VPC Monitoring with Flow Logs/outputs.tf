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

# VPC Flow Logs Outputs
output "flow_log_role_arn" {
  description = "ARN of the IAM role for VPC Flow Logs"
  value       = module.iam.flow_log_role_arn
}

output "vpc_a_log_group_name" {
  description = "Name of the CloudWatch Log Group for VPC A"
  value       = module.cloudwatch_a.log_group_name
}

output "vpc_b_log_group_name" {
  description = "Name of the CloudWatch Log Group for VPC B"
  value       = module.cloudwatch_b.log_group_name
}

output "vpc_a_flow_log_id" {
  description = "ID of VPC A public subnet flow log"
  value       = module.vpc_a.public_subnet_flow_log_id
}

output "vpc_b_flow_log_id" {
  description = "ID of VPC B public subnet flow log"
  value       = module.vpc_b.public_subnet_flow_log_id
}

# Flow Logs Monitoring Commands
output "flow_logs_monitoring_commands" {
  description = "Commands to monitor VPC Flow Logs"
  value = {
    "vpc_a_tail_logs" = "aws logs tail ${module.cloudwatch_a.log_group_name} --follow"
    "vpc_b_tail_logs" = "aws logs tail ${module.cloudwatch_b.log_group_name} --follow"
    "vpc_a_rejected"  = "aws logs filter-log-events --log-group-name ${module.cloudwatch_a.log_group_name} --filter-pattern '[timestamp, account_id, interface_id, srcaddr, dstaddr, srcport, dstport, protocol, packets, bytes, windowstart, windowend, action=REJECT, flowlogstatus]'"
    "vpc_b_rejected"  = "aws logs filter-log-events --log-group-name ${module.cloudwatch_b.log_group_name} --filter-pattern '[timestamp, account_id, interface_id, srcaddr, dstaddr, srcport, dstport, protocol, packets, bytes, windowstart, windowend, action=REJECT, flowlogstatus]'"
    "vpc_a_accepted"  = "aws logs filter-log-events --log-group-name ${module.cloudwatch_a.log_group_name} --filter-pattern '[timestamp, account_id, interface_id, srcaddr, dstaddr, srcport, dstport, protocol, packets, bytes, windowstart, windowend, action=ACCEPT, flowlogstatus]'"
    "vpc_b_accepted"  = "aws logs filter-log-events --log-group-name ${module.cloudwatch_b.log_group_name} --filter-pattern '[timestamp, account_id, interface_id, srcaddr, dstaddr, srcport, dstport, protocol, packets, bytes, windowstart, windowend, action=ACCEPT, flowlogstatus]'"
  }
}