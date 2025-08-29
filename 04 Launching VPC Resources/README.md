# 04 — Launching VPC Resources (Complete VPC with EC2 Instances)

This directory contains a complete Terraform configuration that builds a full VPC environment with both public and private resources, including EC2 instances, security groups, NACLs, and proper connectivity testing.

## Architecture Overview

The configuration creates:
- **1 VPC** with DNS resolution enabled
- **2 Subnets**: 1 public (internet-accessible) and 1 private (internal-only)
- **2 Route Tables**: separate routing for public and private subnets
- **1 Internet Gateway** attached to the public route table
- **2 Custom NACLs**: fine-grained subnet-level access control
- **2 Security Groups**: instance-level firewalls for public and private resources
- **2 EC2 Instances**: 1 in public subnet (with public IP) and 1 in private subnet

## Files Structure

- `main.tf` — Main infrastructure resources (VPC, subnets, IGW, route tables, NACLs, security groups, EC2 instances)
- `variables.tf` — Input variables for customization (VPC CIDR, subnet CIDRs, instance type, etc.)
- `data.tf` — Data sources (availability zones, latest AMI)
- `provider.tf` — AWS provider configuration
- `outputs.tf` — Key resource IDs and connection information
- `screenshots/` — Connectivity test screenshots demonstrating network functionality
- `README.md` — This documentation

## Network Architecture & Traffic Flow

### Public Subnet (Internet-Connected)
```
Internet ↔ Internet Gateway ↔ Public Route Table ↔ Public Subnet ↔ Public EC2
```

**Key Components:**
- **Route Table**: Contains `0.0.0.0/0 → IGW` route for internet access
- **NACL Rules**: Allows HTTP (80), HTTPS (443), SSH (22), and ICMP traffic
- **Security Group**: Allows SSH (22) inbound and ICMP; all traffic outbound
- **EC2 Instance**: Has public IP assigned automatically

### Private Subnet (Internal-Only)
```
Public EC2 ↔ Public NACL ↔ Private NACL ↔ Private Subnet ↔ Private EC2
```

**Key Components:**
- **Route Table**: No internet gateway route (internal VPC traffic only)
- **NACL Rules**: Bidirectional ICMP rules for ping connectivity within VPC
- **Security Group**: Allows ICMP from/to VPC CIDR range
- **EC2 Instance**: No public IP (accessible only from within VPC)

## NACL Configuration (Stateless Rules)

### Public Subnet NACL
**Ingress (Inbound):**
- Rule 100: HTTP (TCP/80) from anywhere
- Rule 110: HTTPS (TCP/443) from anywhere  
- Rule 120: SSH (TCP/22) from anywhere
- Rule 130: ICMP Echo Reply (type 0) from anywhere

**Egress (Outbound):**
- Rule 100: All traffic (`protocol = -1`) to anywhere

### Private Subnet NACL
**Ingress (Inbound):**
- Rule 100: ICMP Echo Request (type 8) from VPC CIDR
- Rule 110: ICMP Echo Reply (type 0) from VPC CIDR

**Egress (Outbound):**
- Rule 100: ICMP Echo Reply (type 0) to VPC CIDR  
- Rule 110: ICMP Echo Request (type 8) to VPC CIDR

## Security Groups (Stateful Rules)

### Public Security Group
- **Ingress**: SSH (22) from anywhere, ICMP from anywhere
- **Egress**: All traffic to anywhere (default)

### Private Security Group  
- **Ingress**: ICMP from VPC CIDR range
- **Egress**: ICMP to VPC CIDR range

## Connectivity Testing & Results

The infrastructure supports the following connectivity patterns:

### 1. Internet Connectivity (Public Instance → Internet)
**Test**: `ping example.com` from public EC2 instance

![Internet Connectivity Test](screenshots/1%20ping%20example%20dot%20com.png)

**Flow**: Public EC2 → Public SG → Public NACL → IGW → Internet → example.com
- ✅ **Working**: Public instance can reach external websites
- **Why it works**: Public route table has `0.0.0.0/0 → IGW` route, NACL allows ICMP, SG allows all outbound

### 2. Internal VPC Connectivity (Public Instance → Private Instance)  
**Test**: `ping <private-instance-ip>` from public EC2 instance

![Internal VPC Connectivity Test](screenshots/2%20ping%20private%20instance.png)

**Flow**: Public EC2 → Public SG → Public NACL → Private NACL → Private SG → Private EC2
- ✅ **Working**: Public instance can ping private instance within VPC
- **Why it works**: Both NACLs have bidirectional ICMP rules, Security Groups allow ICMP within VPC CIDR

## Key Implementation Details

### ICMP Configuration for Ping
Since NACLs are **stateless**, bidirectional ICMP requires explicit rules:
- **Type 8**: Echo Request (outgoing ping)  
- **Type 0**: Echo Reply (incoming ping response)

### Security Design Patterns
- **Layered Security**: Route Tables → NACLs → Security Groups
- **Public Subnet**: Internet-facing resources (web servers, load balancers)
- **Private Subnet**: Internal resources (databases, application servers)
- **No Direct Internet**: Private subnet has no IGW route, accessible only via public subnet

## Usage

1. **Initialize Terraform:**
```bash
terraform init
```

2. **Plan Deployment:**
```bash
terraform plan
```

3. **Deploy Infrastructure:**
```bash
terraform apply
```

4. **Connect to Public Instance:**
   - Use EC2 Instance Connect or SSH with the key pair
   - Public IP address available in outputs

5. **Test Connectivity:**
   - From public instance: `ping example.com` (internet)
   - From public instance: `ping <private-ip>` (internal VPC)

## Outputs

- `vpc_id` — VPC identifier
- `public_subnet_id` & `private_subnet_id` — Subnet identifiers
- `public_instance_id` & `private_instance_id` — EC2 instance identifiers  
- `public_instance_ip` — Public IP address for SSH access
- `private_instance_ip` — Private IP for internal connectivity testing

## AWS Solutions Architect Exam Relevance

This configuration demonstrates key exam concepts:

- **VPC Design**: Public/private subnet patterns for multi-tier applications
- **Security Layers**: Understanding NACL vs Security Group differences and use cases
- **Routing**: How route tables control traffic flow and internet connectivity
- **Instance Connectivity**: Public IP assignment, internet gateway routing
- **Troubleshooting**: Network connectivity issues and systematic debugging

## Troubleshooting Network Issues

**Common Issues & Solutions:**

1. **Ping to internet fails**: Check public route table has IGW route, NACL allows ICMP
2. **Ping between instances fails**: Verify bidirectional NACL rules, Security Group rules
3. **SSH connection fails**: Check Security Group port 22 rules, NACL SSH rules
4. **NACL rule conflicts**: Ensure unique rule numbers, no duplicate entries

**Debug Flow:**
1. Check Route Tables (routing scope)
2. Check NACL Rules (subnet-level filtering) 
3. Check Security Groups (instance-level filtering)
4. Check Instance networking configuration

## Clean Up

```bash
terraform destroy
```

**Note**: Always clean up resources to avoid ongoing AWS charges. The destroy command removes all created resources in the correct dependency order.
