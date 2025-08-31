# Project 09: VPC Endpoints for S3 Access

## 🎯 Project Overview

This project demonstrates how to implement **VPC Gateway Endpoints** for secure, private S3 access without internet routing. The infrastructure restricts S3 bucket access to only come through the VPC endpoint, providing enhanced security and cost optimization by keeping traffic within AWS's private network.

## 🏗️ Architecture Components

### Core Infrastructure
- **VPC**: Custom VPC with public subnet and internet gateway
- **S3 Gateway Endpoint**: Route table-attached endpoint for private S3 access
- **S3 Bucket**: Demo bucket with versioning, encryption, and NextWork sample images
- **EC2 Instance**: Testing environment with comprehensive management scripts
- **IAM Role**: EC2 instance role with S3 access and bucket policy management permissions
- **Security Groups & NACLs**: Network-level access controls

### Key Features
- ✅ **Private S3 Access**: All S3 traffic routes through VPC endpoint (no internet)
- ✅ **Restrictive Bucket Policy**: Optional policy to enforce VPC endpoint-only access
- ✅ **Management Scripts**: Tools for policy management and testing
- ✅ **Sample Data**: NextWork demo images for testing
- ✅ **Operational Flexibility**: Scripts to apply/remove restrictions as needed

## 📁 Project Structure

```
09 VPC Endpoints/
├── main.tf                 # Main Terraform configuration
├── variables.tf           # Variable definitions
├── outputs.tf            # Output values
├── data.tf              # Data sources
├── provider.tf          # Provider configuration
├── modules/
│   ├── vpc/             # VPC and VPC endpoint resources
│   ├── s3/              # S3 bucket and objects
│   ├── compute/         # EC2 instance with management scripts
│   ├── iam/            # IAM roles and policies
│   └── security/       # Security groups and NACLs
├── screenshots/        # Project demonstration screenshots
└── README.md          # This documentation
```

## 🚀 Deployment Instructions

### Prerequisites
- AWS CLI configured with appropriate permissions
- Terraform >= 1.0 installed
- AWS account with VPC, S3, and EC2 permissions

### Step 1: Deploy Infrastructure
```bash
# Navigate to project directory
cd "09 VPC Endpoints"

# Initialize Terraform
terraform init

# Review planned changes
terraform plan

# Deploy infrastructure
terraform apply -auto-approve
```

### Step 2: Get Connection Details
```bash
# Display connection instructions and infrastructure details
terraform output
```

## 🧪 Testing VPC Endpoint Functionality

### Connect to EC2 Instance

**Option 1: AWS Session Manager (Recommended)**
1. Go to AWS Console → EC2 → Instances
2. Select `nextwork-vpc-public-ec2`
3. Click **Connect** → **Session Manager**

**Option 2: SSH (if key pair configured)**
```bash
ssh -i your-key.pem ec2-user@<instance-ip>
```

### Available Testing Scripts

#### Quick S3 Access Test
```bash
# Run comprehensive S3 access test
./test-s3-access.sh
```

#### VPC Endpoint Management Scripts
```bash
# View available management tools
ls -la vpc-management/

# Get usage instructions
./vpc-management/README.sh
```

### Manual AWS CLI Testing
```bash
# List all S3 buckets
aws s3 ls

# List bucket contents
aws s3 ls s3://nextwork-vpc-s3-demo-bucket-<suffix>

# Download NextWork demo images
aws s3 cp s3://nextwork-vpc-s3-demo-bucket-<suffix>/nextwork-denzel-awesome.png /tmp/
aws s3 cp s3://nextwork-vpc-s3-demo-bucket-<suffix>/nextwork-lelo-awesome.png /tmp/

# Upload test file
echo "Hello VPC Endpoint!" > /tmp/test.txt
aws s3 cp /tmp/test.txt s3://nextwork-vpc-s3-demo-bucket-<suffix>/test-uploads/
```

## 🔒 Security Testing Workflow

### Phase 1: Normal Access Testing
1. **Deploy Infrastructure**: `terraform apply`
2. **Test Basic Access**: Run `./test-s3-access.sh`
3. **Verify VPC Endpoint**: Confirm traffic routes through endpoint

### Phase 2: Restrictive Policy Testing
1. **Apply Restriction**: 
   ```bash
   ./vpc-management/apply-restrictive-policy.sh <bucket-name> <vpc-endpoint-id>
   ```
2. **Test VPC Access**: Confirm EC2 instance can still access S3
3. **Test External Block**: Try accessing from AWS Console (should fail)
4. **Verify Upload Restrictions**: Test uploads from internet vs VPC

### Phase 3: Policy Management
1. **Remove Restriction**: 
   ```bash
   ./vpc-management/remove-bucket-policy.sh <bucket-name>
   ```
2. **Restore Normal Access**: Verify external access works again

## 📸 Project Screenshots

### 1. Initial Setup and File Exploration
![EC2 Instance Files](screenshots/1%20showing%20files%20and%20directories%20available%20on%20EC2%20instance.png)
*Showing the management scripts and tools available on the EC2 instance*

### 2. S3 Access Without Restrictions
![S3 Access Test](screenshots/2%20testing%20access%20to%20s3%20without%20restrictive%20bucket%20policy.png)
*Testing S3 access before applying restrictive bucket policy*

### 3. S3 Bucket Contents
![S3 Bucket Contents](screenshots/3%20showing%20content%20of%20s3%20bucket.png)
*Displaying the NextWork demo images and bucket contents*

### 4. Applying Restrictive Bucket Policy
![Apply Bucket Policy](screenshots/4%20apply%20restrictive%20bucket%20policy%20for%20getting,%20updating%20and%20deleting%20objects.png)
*Applying the VPC endpoint-only access restriction policy*

### 5. Upload Attempt from Console
![Console Upload Attempt](screenshots/5%20uploading%20object%20via%20s3%20console.png)
*Attempting to upload file through S3 Console (internet access)*

### 6. Upload Failure Due to Policy
![Upload Failure](screenshots/6%20showing%20failure%20of%20upload.png)
*Upload fails due to restrictive policy blocking internet access*

### 7. Successful VPC Endpoint Access
![VPC Endpoint Success](screenshots/7%20showing%20upload%20and%20download%20of%20objects%20via%20instance.png)
*Successful upload and download through EC2 instance via VPC endpoint*

### 8. Console Shows VPC Upload
![Console Shows Upload](screenshots/8%20showing%20uploaded%20file%20on%20console.png)
*File uploaded via VPC endpoint now visible in S3 Console*

### 9. Bucket Policy Details
![Bucket Policy](screenshots/9%20showing%20restrictive%20bucket%20policy.png)
*The restrictive bucket policy configuration in AWS Console*

### 10. Policy Removal Process
![Remove Policy](screenshots/10%20%20removing%20bucket%20policy%20so%20terraform%20can%20manage%20resources.png)
*Removing restrictive policy to allow Terraform management*

### 11. Policy Successfully Removed
![Policy Removed](screenshots/11%20showing%20removed%20bucket%20policy.png)
*Confirmation that bucket policy has been removed*

## 🔧 Key Configuration Details

### VPC Gateway Endpoint
```terraform
resource "aws_vpc_endpoint" "s3" {
  vpc_id              = aws_vpc.main.id
  service_name        = data.aws_vpc_endpoint_service.s3.service_name
  vpc_endpoint_type   = "Gateway"
  route_table_ids     = [aws_route_table.rt.id]
  policy             = data.aws_iam_policy_document.s3_vpc_endpoint_policy.json
}
```

### Restrictive S3 Bucket Policy
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "VPCEndpointAccessOnly",
      "Effect": "Allow",
      "Principal": "*",
      "Action": ["s3:GetObject", "s3:PutObject", "s3:ListBucket"],
      "Condition": {
        "StringEquals": {
          "aws:sourceVpce": "vpce-xxxxxxxx"
        }
      }
    },
    {
      "Sid": "DenyNonVPCEndpointAccess", 
      "Effect": "Deny",
      "Principal": "*",
      "Action": ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"],
      "Condition": {
        "StringNotEquals": {
          "aws:sourceVpce": "vpce-xxxxxxxx"
        }
      }
    }
  ]
}
```

## 📊 Infrastructure Outputs

After successful deployment, you'll receive:

```
connection_instructions = "Complete testing guide with EC2 connection details"
iam_role_name = "nextwork-vpc-ec2-s3-role"
instance_profile_name = "nextwork-vpc-ec2-s3-profile" 
s3_bucket_arn = "arn:aws:s3:::nextwork-vpc-s3-demo-bucket-xxxxx"
s3_bucket_name = "nextwork-vpc-s3-demo-bucket-xxxxx"
s3_vpc_endpoint_id = "vpce-xxxxxxxxxxxxx"
s3_vpc_endpoint_prefix_list_id = "pl-xxxxxxxx"
uploaded_images = {
  "nextwork_denzel_image" = "nextwork-denzel-awesome.png"
  "nextwork_lelo_image" = "nextwork-lelo-awesome.png"
}
vpc_id = "vpc-xxxxxxxxxxxxx"
vpc_public_instance_ip = "x.x.x.x"
```

## 🛠️ Management Scripts Reference

| Script | Purpose | Usage |
|--------|---------|-------|
| `test-s3-access.sh` | Comprehensive S3 functionality test | `./test-s3-access.sh` |
| `apply-restrictive-policy.sh` | Apply VPC endpoint-only policy | `./vpc-management/apply-restrictive-policy.sh <bucket> <endpoint>` |
| `remove-bucket-policy.sh` | Remove bucket policy for cleanup | `./vpc-management/remove-bucket-policy.sh <bucket>` |
| `test-vpc-endpoint-access.sh` | Test VPC endpoint connectivity | `./vpc-management/test-vpc-endpoint-access.sh <bucket>` |
| `README.sh` | Display usage instructions | `./vpc-management/README.sh` |

## 🧹 Cleanup Instructions

### Safe Destruction Process
1. **Remove Restrictive Policy** (if applied):
   ```bash
   ./vpc-management/remove-bucket-policy.sh <bucket-name>
   ```

2. **Destroy Infrastructure**:
   ```bash
   terraform destroy -auto-approve
   ```

### Force Cleanup (if needed)
```bash
# If bucket policy causes issues
aws s3api delete-bucket-policy --bucket <bucket-name>
terraform destroy -auto-approve
```

## 🎓 Learning Outcomes

After completing this project, you will understand:

- ✅ **VPC Gateway Endpoints**: How to implement private AWS service access
- ✅ **S3 Security Policies**: Advanced bucket policy conditions and restrictions  
- ✅ **Network Traffic Routing**: How VPC endpoints affect data flow
- ✅ **Cost Optimization**: Reducing data transfer costs through private routing
- ✅ **Operational Management**: Policy management and testing workflows
- ✅ **Security Best Practices**: Implementing defense-in-depth with network controls

## 🔍 Key Concepts Demonstrated

### VPC Gateway Endpoint Benefits
- **Security**: Traffic never leaves AWS network
- **Cost**: No NAT Gateway or internet data transfer charges
- **Performance**: Lower latency through direct AWS backbone routing
- **Compliance**: Meets requirements for private connectivity

### S3 Bucket Policy Restrictions
- **Condition-Based Access**: Using `aws:sourceVpce` condition
- **Explicit Deny**: Blocking non-VPC endpoint access
- **Principal Wildcards**: Allowing authenticated users through specific paths
- **Action Granularity**: Fine-grained permission control

## 🚨 Important Notes

- **Policy Impact**: Restrictive bucket policies affect all access methods
- **Terraform Management**: Remove policies before `terraform destroy`
- **Development vs Production**: Use restrictive policies carefully in production
- **Monitoring**: Monitor VPC Flow Logs to verify endpoint usage
- **Costs**: Gateway endpoints have no hourly charges, only data processing fees

## 📚 Additional Resources

- [AWS VPC Endpoints Documentation](https://docs.aws.amazon.com/vpc/latest/privatelink/vpc-endpoints.html)
- [S3 Bucket Policy Examples](https://docs.aws.amazon.com/AmazonS3/latest/userguide/bucket-policies.html)
- [VPC Endpoint Policy Examples](https://docs.aws.amazon.com/vpc/latest/privatelink/vpc-endpoints-access.html)

---

**Project 09 - VPC Endpoints Implementation**  
*NextWork VPC Practice Series*