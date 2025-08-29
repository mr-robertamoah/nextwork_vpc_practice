# 07 — VPC Monitoring with Flow Logs

This project extends VPC peering functionality with **VPC Flow Logs** and **CloudWatch monitoring**. It demonstrates how to implement comprehensive network monitoring using a **modular Terraform architecture** to create two VPCs with peering connection while capturing all network traffic to CloudWatch Logs for security monitoring and troubleshooting.

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                   VPC Monitoring Architecture                   │
└─────────────────────────────────────────────────────────────────┘

VPC A (10.1.0.0/16)                    VPC B (10.2.0.0/16)
├── Public Subnet (10.1.1.0/24)       ├── Public Subnet (10.2.1.0/24)
│   ├── EC2 Instance (Public IP)       │   ├── EC2 Instance (Public IP)
│   └── 🔍 Flow Logs → CloudWatch      │   └── 🔍 Flow Logs → CloudWatch
├── Private Subnet (10.1.2.0/24)      ├── Private Subnet (10.2.2.0/24)
│   └── EC2 Instance (Private IP)      │   └── EC2 Instance (Private IP)
└── Internet Gateway                   └── Internet Gateway
                    ↓
            VPC Peering Connection
                    ↓
        Cross-VPC Communication Enabled

CloudWatch Logs
├── /aws/vpc/flowlogs/nextwork-vpc-a
│   └── VPC A Public Subnet Traffic
├── /aws/vpc/flowlogs/nextwork-vpc-b
│   └── VPC B Public Subnet Traffic
└── Retention: 7 days (configurable)

IAM Flow Logs Role
├── nextwork-vpc-monitoring-flow-log-role
├── Trust: vpc-flow-logs.amazonaws.com
└── Permissions: CloudWatch Logs write access
```

## Modular Structure

### `/modules/` Directory
- **`vpc/`** - VPC, subnets, route tables, internet gateway, **+ Flow Logs**
- **`security/`** - Network ACLs and security groups with cross-VPC support
- **`compute/`** - EC2 instances with AMI lookup
- **`iam/`** - **NEW:** IAM role and policy for VPC Flow Logs
- **`cloudwatch/`** - **NEW:** CloudWatch Log Groups and Log Streams

### Root Configuration
- **`main.tf`** - Orchestrates modules with VPC peering + Flow Logs
- **`variables.tf`** - Variables for VPCs, peering, and Flow Logs config
- **`outputs.tf`** - Resource IDs, connectivity commands, and monitoring commands
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

### 🔍 **VPC Flow Logs Monitoring** *(NEW)*
- **Public Subnet Monitoring**: Captures all traffic in both VPC public subnets
- **CloudWatch Integration**: Logs stored in separate CloudWatch Log Groups per VPC
- **Configurable Traffic Types**: ALL, ACCEPT, or REJECT traffic logging
- **IAM Security**: Dedicated role with minimal permissions for Flow Logs service
- **Cost Control**: Configurable log retention (default 7 days)

### 📊 **Advanced Monitoring** *(NEW)*
- **Real-time Traffic Analysis**: Monitor network patterns and security events
- **Cross-VPC Traffic Visibility**: Track communication between peered VPCs
- **Security Incident Response**: Identify suspicious network activity
- **Compliance Logging**: Meet regulatory requirements for network monitoring

## Module Details

### VPC Module (`modules/vpc/`) *(Enhanced)*
Creates the foundational network infrastructure **with Flow Logs**:
- VPC with DNS support enabled
- Public subnet with internet gateway route
- Private subnet with VPC-local routing only  
- Route tables and associations
- **NEW:** VPC Flow Logs for public subnet traffic monitoring
- **NEW:** Configurable traffic type filtering (ALL/ACCEPT/REJECT)

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

### Compute Module (`modules/compute/`)
Provisions EC2 instances:
- Latest Amazon Linux AMI lookup
- Public instance with public IP assignment
- Private instance with VPC-internal access only
- Appropriate security group assignments

### IAM Module (`modules/iam/`) *(NEW)*
Creates IAM resources for VPC Flow Logs:
- **Role**: `nextwork-vpc-monitoring-flow-log-role`
- **Trust Policy**: Allows `vpc-flow-logs.amazonaws.com` to assume role
- **Policy**: Minimal permissions for CloudWatch Logs operations
- **Security**: Least privilege access for Flow Logs service

### CloudWatch Module (`modules/cloudwatch/`) *(NEW)*
Sets up CloudWatch Logs infrastructure:
- **Log Groups**: `/aws/vpc/flowlogs/{vpc-name}` per VPC
- **Log Streams**: Individual streams for organized logging
- **Retention**: Configurable retention period (default 7 days)
- **Monitoring Ready**: Prepared for CloudWatch Insights queries

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

### 3. **Monitor VPC Flow Logs** *(NEW)*

Use the output commands to monitor network traffic:

```bash
# Get Flow Logs monitoring commands
terraform output flow_logs_monitoring_commands

# Example commands:
# Tail live Flow Logs for VPC A
aws logs tail /aws/vpc/flowlogs/nextwork-vpc-a --follow

# View rejected connections in VPC B
aws logs filter-log-events --log-group-name /aws/vpc/flowlogs/nextwork-vpc-b \
  --filter-pattern '[timestamp, account_id, interface_id, srcaddr, dstaddr, srcport, dstport, protocol, packets, bytes, windowstart, windowend, action=REJECT, flowlogstatus]'
```

### 4. **Sample Flow Log Entry**

Flow logs appear in CloudWatch with this format:
```
2 123456789012 eni-abc12345 10.1.1.5 8.8.8.8 443 32768 6 10 840 1620663600 1620663660 ACCEPT OK
```
Fields: `version account-id interface-id srcaddr dstaddr srcport dstport protocol packets bytes windowstart windowend action flowlogstatus`

### 5. **CloudWatch Insights Queries**

Analyze traffic patterns using CloudWatch Logs Insights:

```sql
-- Find rejected connections
fields @timestamp, srcaddr, dstaddr, srcport, dstport, action
| filter action = "REJECT"
| sort @timestamp desc
| limit 100

-- Cross-VPC traffic analysis
fields @timestamp, srcaddr, dstaddr, dstport, action
| filter (srcaddr like /^10\.1\./ and dstaddr like /^10\.2\./) 
    or (srcaddr like /^10\.2\./ and dstaddr like /^10\.1\./)
| sort @timestamp desc

-- HTTP/HTTPS traffic patterns
fields @timestamp, srcaddr, dstaddr, dstport, action, packets
| filter dstport = 80 or dstport = 443
| stats sum(packets) by dstport, action
| sort sum desc
```

## VPC Flow Logs Implementation Results

This section demonstrates the successful implementation of VPC Flow Logs with CloudWatch monitoring for both VPCs, providing complete network traffic visibility.

### CloudWatch Log Groups Setup

**Separate Log Groups for Each VPC**
- VPC A Flow Logs: `/aws/vpc/flowlogs/nextwork-vpc-a`
- VPC B Flow Logs: `/aws/vpc/flowlogs/nextwork-vpc-b`
- Log retention: 7 days (configurable)

![CloudWatch Log Groups for Both VPCs](screenshots/3%20log%20groups%20for%20public%20subnets%20for%20both%20VPCs.png)

### VPC A Flow Logs in Action

**Real-time Traffic Monitoring for VPC A Public Subnet**
- Captures all network traffic (ACCEPT/REJECT/ALL)
- Logs include source/destination IPs, ports, protocols, and actions
- Integration with CloudWatch for querying and analysis

![VPC A Flow Logs](screenshots/1%20flow%20logs%20of%20vpc_a%20public%20subnet.png)

### VPC B Flow Logs in Action  

**Real-time Traffic Monitoring for VPC B Public Subnet**
- Parallel logging infrastructure for VPC B
- Independent log streams for organized monitoring
- Complete visibility into cross-VPC communications

![VPC B Flow Logs](screenshots/2%20flow%20logs%20of%20vpc_b%20public%20subnet.png)

### Flow Logs from External Connections

**Monitoring External Traffic to VPC A**
- Flow logs capture ping requests from local machines
- Shows external IP addresses connecting to public instances
- Demonstrates security monitoring capabilities

![Flow Logs from Pings to VPC A](screenshots/12%20flow%20logs%20from%20pings%20made%20to%20vpc_a%20public%20instance%20.png)

**Monitoring External Traffic to VPC B**
- Consistent logging across both VPCs
- Complete audit trail for security compliance
- Real-time visibility into network patterns

![Flow Logs from Pings to VPC B](screenshots/13%20flow%20logs%20from%20pings%20made%20to%20vpc_b%20public%20instance.png)

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

This section demonstrates various connectivity scenarios between VPC A and VPC B instances, including external connectivity from local machines, with actual ping test results captured in screenshots.

### External Connectivity Tests *(NEW)*

**Local Machine → VPC A Public Instance**
- ✅ Successfully pings VPC A public instance from local machine
- Demonstrates proper security group and NACL configuration for external access
- Shows Flow Logs capturing external traffic

![Ping VPC A Public Instance from Local](screenshots/7%20ping%20%20vpc_a%20public%20instance%20from%20local.png)

**Local Machine → VPC B Public Instance**
- ✅ Successfully pings VPC B public instance from local machine  
- Confirms consistent external connectivity across both VPCs
- Flow Logs capture all external connections for security monitoring

![Ping VPC B Public Instance from Local](screenshots/11%20ping%20%20vpc_b%20public%20instance%20from%20local.png)

### Internet Connectivity Tests

**VPC A Public Instance → Internet**
- ✅ Successfully pings external sites (example.com)
- Outbound internet connectivity working properly

![VPC A Public Instance pinging example.com](screenshots/4%20ping%20example%20dot%20com%20from%20vpc_a%20public%20instance.png)

**VPC B Public Instance → Internet** 
- ✅ Successfully pings external sites (example.com)
- Both VPCs have independent internet access

![VPC B Public Instance pinging example.com](screenshots/8%20ping%20example%20dot%20com%20from%20vpc_b%20public%20instance.png)

### Intra-VPC Connectivity Tests

**VPC A Public → VPC A Private Instance**
- ✅ Successful ping within VPC A (10.1.x.x network)
- Tests security group and NACL rules within same VPC

![VPC A Public to VPC A Private Instance](screenshots/5%20ping%20vpc_a%20private%20instance%20from%20vpc_a%20public%20instance.png)

**VPC B Public → VPC B Private Instance**
- ✅ Successful ping within VPC B (10.2.x.x network) 
- Tests security group and NACL rules within same VPC

![VPC B Public to VPC B Private Instance](screenshots/9%20ping%20vpc_b%20private%20instance%20from%20vpc_b%20public%20instance.png)

### Cross-VPC Connectivity Tests (VPC Peering)

**VPC A Public → VPC B Private Instance**
- ✅ **Successful cross-VPC ping** (10.1.x.x → 10.2.x.x)
- Demonstrates VPC peering functionality
- Tests route tables, NACL rules, and security groups across VPC boundary

![VPC A Public to VPC B Private Instance (Cross-VPC)](screenshots/6%20ping%20vpc_b%20private%20instance%20from%20vpc_a%20public%20instance.png)

**VPC B Public → VPC A Private Instance**
- ✅ **Successful cross-VPC ping** (10.2.x.x → 10.1.x.x)
- Confirms bidirectional VPC peering communication
- Tests reverse path through peering connection

![VPC B Public to VPC A Private Instance (Cross-VPC)](screenshots/10%20ping%20vpc_a%20private%20instance%20from%20vpc_b%20public%20instance.png)

### Connectivity Summary

| Source | Destination | Network Path | Status | Screenshot |
|--------|------------|--------------|--------|------------|
| **Local Machine** | **VPC A Public** | **Internet → IGW → VPC A** | **✅ Success** | [Screenshot #7](screenshots/7%20ping%20%20vpc_a%20public%20instance%20from%20local.png) |
| **Local Machine** | **VPC B Public** | **Internet → IGW → VPC B** | **✅ Success** | [Screenshot #11](screenshots/11%20ping%20%20vpc_b%20public%20instance%20from%20local.png) |
| VPC A Public | Internet (example.com) | IGW → Internet | ✅ Success | [Screenshot #4](screenshots/4%20ping%20example%20dot%20com%20from%20vpc_a%20public%20instance.png) |
| VPC B Public | Internet (example.com) | IGW → Internet | ✅ Success | [Screenshot #8](screenshots/8%20ping%20example%20dot%20com%20from%20vpc_b%20public%20instance.png) |
| VPC A Public | VPC A Private | Intra-VPC routing | ✅ Success | [Screenshot #5](screenshots/5%20ping%20vpc_a%20private%20instance%20from%20vpc_a%20public%20instance.png) |
| VPC B Public | VPC B Private | Intra-VPC routing | ✅ Success | [Screenshot #9](screenshots/9%20ping%20vpc_b%20private%20instance%20from%20vpc_b%20public%20instance.png) |
| VPC A Public | VPC B Private | **Cross-VPC via peering** | ✅ Success | [Screenshot #6](screenshots/6%20ping%20vpc_b%20private%20instance%20from%20vpc_a%20public%20instance.png) |
| VPC B Public | VPC A Private | **Cross-VPC via peering** | ✅ Success | [Screenshot #10](screenshots/10%20ping%20vpc_a%20private%20instance%20from%20vpc_b%20public%20instance.png) |

### Network Architecture Validation

These test results confirm that our modular Terraform configuration has successfully implemented:

1. **✅ Proper VPC Peering Setup**
   - Route tables updated in all subnets
   - Peering connection active and accepting traffic
   - Bidirectional communication working

2. **✅ Security Group Configuration**
   - ICMP traffic allowed within VPCs
   - Cross-VPC ICMP traffic properly configured
   - External access from local machines enabled
   - Both ingress and egress rules working

3. **✅ Network ACL Rules**
   - Public subnet NACLs allow external ICMP (ping requests & replies)
   - Private subnet NACLs allow ICMP from own VPC CIDR
   - Private subnet NACLs allow ICMP from peer VPC CIDR
   - Stateless rules properly configured for both directions

4. **✅ VPC Flow Logs Implementation** *(NEW)*
   - Flow Logs enabled for both VPC public subnets
   - Separate CloudWatch Log Groups for each VPC
   - Real-time capture of all network traffic
   - External connections properly logged and monitored

5. **✅ Route Table Management**
   - Internet gateway routes for public subnets
   - VPC peering routes added to all route tables
   - Private instances can reach peered VPC without internet access
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

## Project Summary: VPC Peering + Flow Logs Success

This project demonstrates a **complete enterprise-ready networking solution** that combines VPC peering with comprehensive monitoring:

### 🎯 **Key Achievements Demonstrated**

#### **VPC Peering Implementation**
- ✅ **Dual VPC Architecture**: Two fully independent VPCs with cross-communication
- ✅ **Bidirectional Connectivity**: Successful pings in both directions across VPC boundary  
- ✅ **Route Table Management**: Automatic route updates for seamless peering
- ✅ **Security Configuration**: NACLs and Security Groups properly configured for cross-VPC traffic

#### **VPC Flow Logs & Monitoring**
- ✅ **Complete Traffic Visibility**: Real-time logging of all public subnet network traffic
- ✅ **Separate Log Groups**: Independent CloudWatch monitoring for each VPC
- ✅ **External Access Monitoring**: Captures and logs external connections from internet
- ✅ **Security Event Tracking**: Full audit trail for compliance and incident response

#### **Production-Ready Features**
- ✅ **Modular Architecture**: Reusable Terraform modules for scalability
- ✅ **IAM Security**: Least-privilege roles for Flow Logs service access
- ✅ **Cost Control**: Configurable log retention and traffic filtering
- ✅ **Comprehensive Testing**: All connectivity scenarios validated with screenshots

### 📊 **Visual Evidence Provided**
- **13 Screenshots** documenting all connectivity scenarios and Flow Logs functionality
- **Network Flow Logs** showing actual traffic patterns and security monitoring
- **CloudWatch Integration** demonstrating real-time monitoring capabilities
- **Cross-VPC Communication** proving successful peering implementation

This implementation serves as a **blueprint for enterprise AWS networking** with security monitoring, combining the power of VPC peering for multi-tier architectures with comprehensive Flow Logs for security compliance and troubleshooting.

## AWS Solutions Architect Exam Relevance

This enhanced project demonstrates:

- **VPC Peering**: Cross-region/cross-account communication patterns
- **VPC Flow Logs**: Network monitoring and security compliance
- **CloudWatch Integration**: Log management and retention strategies
- **IAM Best Practices**: Service-specific roles with minimal permissions
- **Module Design**: Reusable infrastructure components  
- **Security Layers**: Defense in depth with NACLs + Security Groups
- **Route Management**: How peering affects routing tables
- **Network Troubleshooting**: Systematic approach to connectivity issues
- **Cost Optimization**: Monitoring cost management with configurable retention

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
