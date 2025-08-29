# 06 — VPC Peering with Terraform Modules

This directory demonstrates VPC peering using a **modular Terraform architecture**. The configuration creates two complete VPC environments and connects them via VPC peering, allowing resources in different VPCs to communicate privately.

## Architecture Overview

```
VPC A (10.1.0.0/16)                    VPC B (10.2.0.0/16)
├── Public Subnet (10.1.1.0/24)       ├── Public Subnet (10.2.1.0/24)
│   └── EC2 Instance (Public IP)       │   └── EC2 Instance (Public IP)
├── Private Subnet (10.1.2.0/24)      ├── Private Subnet (10.2.2.0/24)
│   └── EC2 Instance (Private IP)      │   └── EC2 Instance (Private IP)
└── Internet Gateway                   └── Internet Gateway
                    ↓
            VPC Peering Connection
                    ↓
        Cross-VPC Communication Enabled
```

## Modular Structure

### `/modules/` Directory
- **`vpc/`** - VPC, subnets, route tables, internet gateway
- **`security/`** - Network ACLs and security groups
- **`compute/`** - EC2 instances with AMI lookup

### Root Configuration
- **`main.tf`** - Orchestrates modules and creates VPC peering
- **`variables.tf`** - Input variables for both VPCs and global settings
- **`outputs.tf`** - Key resource IDs and connectivity test commands
- **`provider.tf`** - AWS provider configuration

## Key Features

### 🚀 **Reusability**
- Each module can be used independently or combined
- Easy to add more VPCs by calling modules with different parameters
- Consistent resource naming and tagging across environments

### 🔒 **Security Configuration**
- **NACLs**: Subnet-level stateless filtering
- **Security Groups**: Instance-level stateful filtering  
- **ICMP Rules**: Properly configured for cross-VPC ping testing

### 🔗 **VPC Peering Setup**
- **Peering Connection**: Automated creation and acceptance
- **Route Updates**: Automatic route table updates in all subnets
- **DNS Resolution**: Enabled for cross-VPC hostname resolution

## Module Details

### VPC Module (`modules/vpc/`)
Creates the foundational network infrastructure:
- VPC with DNS support enabled
- Public subnet with internet gateway route
- Private subnet with VPC-local routing only  
- Route tables and associations

### Security Module (`modules/security/`)
Implements layered security controls with **cross-VPC communication support**:

**Network ACLs (Stateless):**
- Public NACL: HTTP/HTTPS/SSH/ICMP from internet (0.0.0.0/0)
- Private NACL: ICMP bidirectional rules for:
  - Own VPC CIDR (e.g., 10.1.0.0/16)
  - **Peer VPC CIDR** (e.g., 10.2.0.0/16) - *enables cross-VPC ping*

**Security Groups (Stateful):**
- Public SG: SSH (port 22) and ICMP from anywhere (0.0.0.0/0)
- Private SG: ICMP from both own VPC and **peer VPC CIDRs**

**Key Cross-VPC Configuration:**
- Each security module receives `peer_vpc_cidr` variable
- NACL rules include both `icmp_type=8` (ping request) and `icmp_type=0` (ping reply)
- Security groups allow ICMP ingress/egress for both VPC CIDRs
- Enables successful connectivity as shown in screenshots #3 and #6

### Compute Module (`modules/compute/`)
Provisions EC2 instances:
- Latest Amazon Linux AMI lookup
- Public instance with public IP assignment
- Private instance with VPC-internal access only
- Appropriate security group assignments

## Usage

### 1. **Deploy the Infrastructure**

```bash
terraform init
terraform plan
terraform apply
```

### 2. **Test Connectivity**

The outputs provide ready-to-use ping commands:

```bash
terraform output connectivity_test_commands
```

Example output:
```json
{
  "vpc_a_to_vpc_b_private" = "ping 10.2.2.x"
  "vpc_a_to_vpc_b_public" = "ping 10.2.1.x"  
  "vpc_b_to_vpc_a_private" = "ping 10.1.2.x"
  "vpc_b_to_vpc_a_public" = "ping 10.1.1.x"
}
```

## Connectivity Testing Results

This section demonstrates various connectivity scenarios between VPC A and VPC B instances, with actual ping test results captured in screenshots.

### Internet Connectivity Tests

**VPC A Public Instance → Internet**
- ✅ Successfully pings external sites (example.com)

![VPC A Public Instance pinging example.com](screenshots/1%20ping%20example%20dot%20com%20from%20vpc_a%20public%20instance.png)

**VPC B Public Instance → Internet** 
- ✅ Successfully pings external sites (example.com)

![VPC B Public Instance pinging example.com](screenshots/4%20ping%20example%20dot%20com%20from%20vpc_b%20public%20instance.png)

### Intra-VPC Connectivity Tests

**VPC A Public → VPC A Private Instance**
- ✅ Successful ping within VPC A (10.1.x.x network)
- Tests security group and NACL rules within same VPC

![VPC A Public to VPC A Private Instance](screenshots/2%20ping%20vpc_a%20private%20instance%20from%20vpc_a%20public%20instance.png)

**VPC B Public → VPC B Private Instance**
- ✅ Successful ping within VPC B (10.2.x.x network) 
- Tests security group and NACL rules within same VPC

![VPC B Public to VPC B Private Instance](screenshots/5%20ping%20vpc_b%20private%20instance%20from%20vpc_b%20public%20instance.png)

### Cross-VPC Connectivity Tests (VPC Peering)

**VPC A Public → VPC B Private Instance**
- ✅ **Successful cross-VPC ping** (10.1.x.x → 10.2.x.x)
- Demonstrates VPC peering functionality
- Tests route tables, NACL rules, and security groups across VPC boundary

![VPC A Public to VPC B Private Instance (Cross-VPC)](screenshots/3%20ping%20vpc_b%20private%20instance%20from%20vpc_a%20public%20instance.png)

**VPC B Public → VPC A Private Instance**
- ✅ **Successful cross-VPC ping** (10.2.x.x → 10.1.x.x)
- Confirms bidirectional VPC peering communication
- Tests reverse path through peering connection

![VPC B Public to VPC A Private Instance (Cross-VPC)](screenshots/6%20ping%20vpc_a%20private%20instance%20from%20vpc_b%20public%20instance.png)

### Connectivity Summary

| Source | Destination | Network Path | Status | Screenshot |
|--------|------------|--------------|--------|------------|
| VPC A Public | Internet (example.com) | IGW → Internet | ✅ Success | [Screenshot #1](screenshots/1%20ping%20example%20dot%20com%20from%20vpc_a%20public%20instance.png) |
| VPC A Public | VPC A Private | Intra-VPC routing | ✅ Success | [Screenshot #2](screenshots/2%20ping%20vpc_a%20private%20instance%20from%20vpc_a%20public%20instance.png) |
| VPC A Public | VPC B Private | **Cross-VPC via peering** | ✅ Success | [Screenshot #3](screenshots/3%20ping%20vpc_b%20private%20instance%20from%20vpc_a%20public%20instance.png) |
| VPC B Public | Internet (example.com) | IGW → Internet | ✅ Success | [Screenshot #4](screenshots/4%20ping%20example%20dot%20com%20from%20vpc_b%20public%20instance.png) |
| VPC B Public | VPC B Private | Intra-VPC routing | ✅ Success | [Screenshot #5](screenshots/5%20ping%20vpc_b%20private%20instance%20from%20vpc_b%20public%20instance.png) |
| VPC B Public | VPC A Private | **Cross-VPC via peering** | ✅ Success | [Screenshot #6](screenshots/6%20ping%20vpc_a%20private%20instance%20from%20vpc_b%20public%20instance.png) |

### Network Architecture Validation

These test results confirm that our modular Terraform configuration has successfully implemented:

1. **✅ Proper VPC Peering Setup**
   - Route tables updated in all subnets
   - Peering connection active and accepting traffic
   - Bidirectional communication working

2. **✅ Security Group Configuration**
   - ICMP traffic allowed within VPCs
   - Cross-VPC ICMP traffic properly configured
   - Both ingress and egress rules working

3. **✅ Network ACL Rules**
   - Private subnet NACLs allow ICMP from own VPC CIDR
   - Private subnet NACLs allow ICMP from peer VPC CIDR
   - Stateless rules properly configured for both directions

4. **✅ Route Table Management**
   - Internet gateway routes for public subnets
   - VPC peering routes added to all route tables
   - Private instances can reach peered VPC without internet access

### 3. **Access Instances**

Connect to public instances via EC2 Instance Connect:
```bash
# Get public IPs
terraform output vpc_a_public_instance_ip
terraform output vpc_b_public_instance_ip
```

### 4. **Test VPC Peering**

Based on our connectivity tests (see screenshots in `/screenshots/` directory):

From VPC A public instance:
```bash
# Test internet connectivity
ping example.com  # ✅ Works (Screenshot #1)

# Test same-VPC connectivity  
ping <vpc-a-private-ip>  # ✅ Works (Screenshot #2)

# Test cross-VPC connectivity (VPC Peering)
ping <vpc-b-private-ip>  # ✅ Works (Screenshot #3)
```

From VPC B public instance:
```bash
# Test internet connectivity
ping example.com  # ✅ Works (Screenshot #4)

# Test same-VPC connectivity
ping <vpc-b-private-ip>  # ✅ Works (Screenshot #5)  

# Test cross-VPC connectivity (VPC Peering)
ping <vpc-a-private-ip>  # ✅ Works (Screenshot #6)
```

**Key Success Factors:**
- Security groups allow ICMP from both local and peer VPC CIDRs
- NACLs configured with bidirectional ICMP rules for both VPC CIDRs  
- Route tables include routes to peer VPC via peering connection
- VPC peering connection status is "active" and "accepted"

## Customization

### Adding More VPCs

To add VPC C, simply add to `variables.tf` and `main.tf`:

```hcl
# variables.tf
variable "vpc_c_cidr" {
  default = "10.3.0.0/16"
}

# main.tf  
module "vpc_c" {
  source = "./modules/vpc"
  vpc_cidr = var.vpc_c_cidr
  vpc_name = "nextwork-vpc-c"
  subnet_cidrs = ["10.3.1.0/24", "10.3.2.0/24"]
  # ...other configuration
}
```

### Cross-VPC Security

To allow specific traffic between VPCs, update security groups:

```hcl
# Allow SSH from VPC A to VPC B
resource "aws_security_group_rule" "cross_vpc_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22  
  protocol          = "tcp"
  cidr_blocks       = [var.vpc_a_cidr]
  security_group_id = module.security_b.private_security_group_id
}
```

## Network Flow Examples

### Internet Access (Public Instances)
```
Public Instance → Public SG → Public NACL → IGW → Internet
```

### Cross-VPC Communication  
```
VPC A Instance → VPC A SG → VPC A NACL → VPC Peering → VPC B NACL → VPC B SG → VPC B Instance
```

### Internal VPC Communication
```
Public Instance → Public SG → Private NACL → Private SG → Private Instance
```

## Troubleshooting

### Connectivity Test Results ✅

Our configuration has been **thoroughly tested** with successful ping results (see `/screenshots/` directory):
- ✅ Internet connectivity from both VPC public instances
- ✅ Intra-VPC connectivity (public to private within same VPC)  
- ✅ **Cross-VPC connectivity via peering** (both directions)

### Common Issues

**1. Module not found errors:**
```bash
terraform get  # Download modules
terraform init # Re-initialize
```

**2. Cross-VPC ping failures (if they occur):**
- Check route tables have peering routes: `aws ec2 describe-route-tables`
- Verify security groups allow ICMP from peer VPC CIDR
- Ensure NACLs permit bidirectional ICMP for both VPC CIDRs
- Confirm peering connection status is "active"

**3. Resource naming conflicts:**
- Each module uses name prefixes to avoid conflicts
- Tags include VPC name for resource identification

### Validated Network Flows

Based on our successful connectivity tests:

**✅ Internet Access (Working)**
```
Public Instance → Public SG (allows ICMP) → Public NACL (allows all egress) → IGW → Internet
```

**✅ Cross-VPC Communication (Working)**  
```
VPC A Public → VPC A SG (allows ICMP) → VPC A NACL (allows ICMP to peer CIDR) 
→ VPC Peering → VPC B NACL (allows ICMP from peer CIDR) → VPC B SG (allows ICMP from peer CIDR) 
→ VPC B Private Instance
```

**✅ Internal VPC Communication (Working)**
```
Public Instance → Public SG (allows ICMP) → Private NACL (allows ICMP from VPC CIDR) 
→ Private SG (allows ICMP from VPC CIDR) → Private Instance
```

### Debug Commands

```bash
# Check peering connection status
aws ec2 describe-vpc-peering-connections

# Verify route tables
aws ec2 describe-route-tables --filters "Name=vpc-id,Values=<vpc-id>"

# Check security group rules  
aws ec2 describe-security-groups --group-ids <sg-id>
```

## AWS Solutions Architect Exam Relevance

This modular approach demonstrates:

- **VPC Peering**: Cross-region/cross-account communication patterns
- **Module Design**: Reusable infrastructure components  
- **Security Layers**: Defense in depth with NACLs + Security Groups
- **Route Management**: How peering affects routing tables
- **Network Troubleshooting**: Systematic approach to connectivity issues

## Clean Up

```bash
terraform destroy
```

**Note**: Destroy will remove all resources including instances, VPCs, and peering connections in the correct dependency order.

## Benefits of This Modular Approach

✅ **Scalable**: Easy to add more VPCs or modify existing ones  
✅ **Maintainable**: Changes to modules affect all instances consistently  
✅ **Testable**: Each module can be tested independently  
✅ **Reusable**: Modules can be used in other projects  
✅ **Best Practices**: Follows Terraform module conventions and AWS networking patterns
