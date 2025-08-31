# Project 08: Access S3 from a VPC

## 🎯 **Project Overview**

This project demonstrates **secure S3 access from EC2 instances within a VPC** using IAM roles and instance profiles. The infrastructure showcases best practices for cloud storage access without hardcoded credentials, featuring automated S3 bucket creation, NextWork image uploads, and comprehensive access testing.

## 🏗️ **Architecture Components**

### **Core Infrastructure**
- **VPC**: Single VPC with public subnet for internet connectivity
- **EC2 Instance**: Amazon Linux instance with IAM role for S3 access
- **S3 Bucket**: Secure storage with versioning and encryption
- **IAM Role**: Least-privilege access for bucket operations
- **Security Groups**: Controlled network access for EC2

### **Key Features**
- ✅ **IAM Instance Profile**: Secure, temporary credential access
- ✅ **S3 Bucket Policy**: Fine-grained access control
- ✅ **NextWork Images**: Pre-uploaded demonstration content
- ✅ **Automated Testing**: Comprehensive S3 access validation script
- ✅ **Encryption**: Server-side encryption for all S3 objects

## 📁 **Project Structure**

```
08 Access S3 from a VPC/
├── main.tf                    # Main orchestration
├── variables.tf               # Input variables
├── outputs.tf                 # Resource outputs
├── provider.tf                # AWS provider config
├── data.tf                    # Data sources
├── test-s3-access.sh         # S3 access test script
├── screenshots/              # Visual documentation
│   ├── 1 showing s3 test script.png
│   └── 2 showing successful connection with s3.png
└── modules/
    ├── vpc/                  # VPC and networking
    ├── s3/                   # S3 bucket and objects
    │   └── assets/          # NextWork images
    │       ├── NextWork - Denzel is awesome.png
    │       └── NextWork - Lelo is awesome.png
    ├── iam/                  # IAM roles and policies
    ├── security/             # Security groups and NACLs
    └── compute/              # EC2 instances
```

## 🚀 **Deployment Guide**

### **Prerequisites**
- AWS CLI configured with appropriate permissions
- Terraform >= 1.0
- Access to create VPC, EC2, S3, and IAM resources

### **Step 1: Initialize Terraform**
```bash
cd "08 Access S3 from a VPC"
terraform init
```

### **Step 2: Review and Customize Variables**
```bash
# Edit variables.tf or create terraform.tfvars
terraform plan
```

### **Step 3: Deploy Infrastructure**
```bash
terraform apply
```

### **Step 4: Test S3 Access**
After deployment, connect to the EC2 instance and run the test script:

```bash
# Connect via EC2 Instance Connect or SSH
./test-s3-access.sh
```

## 🧪 **S3 Access Testing**

The project includes a comprehensive test script that validates all S3 operations:

![S3 Test Script](screenshots/1%20showing%20s3%20test%20script.png)

### **Test Categories**
1. **Bucket Listing**: Verify permission to list all S3 buckets
2. **Object Listing**: List contents of the project bucket
3. **Image Downloads**: Download NextWork images from S3
4. **Upload Operations**: Test write permissions with temporary files
5. **IAM Role Verification**: Confirm proper role attachment

### **Expected Results**
![Successful S3 Connection](screenshots/2%20showing%20successful%20connection%20with%20s3.png)

## 📊 **NextWork Images Showcase**

The S3 bucket contains two NextWork demonstration images:

### **NextWork - Denzel is awesome.png**
- **Location**: `s3://bucket-name/nextwork-denzel-awesome.png`
- **Size**: ~2.4MB
- **Format**: PNG

![NextWork - Denzel is awesome](modules/s3/assets/NextWork%20-%20Denzel%20is%20awesome.png)

### **NextWork - Lelo is awesome.png**
- **Location**: `s3://bucket-name/nextwork-lelo-awesome.png`
- **Size**: ~2.3MB
- **Format**: PNG

![NextWork - Lelo is awesome](modules/s3/assets/NextWork%20-%20Lelo%20is%20awesome.png)

## 🔐 **Security Implementation**

### **IAM Role Configuration**
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["s3:ListAllMyBuckets"],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject",
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::bucket-name",
        "arn:aws:s3:::bucket-name/*"
      ]
    }
  ]
}
```

### **S3 Security Features**
- **Bucket Encryption**: AES256 server-side encryption
- **Versioning**: Enabled for object history
- **Public Access Block**: All public access blocked
- **Private ACL**: All objects private by default

## 🛠️ **Manual Testing Commands**

Once connected to the EC2 instance:

```bash
# List all buckets
aws s3 ls

# List bucket contents
aws s3 ls s3://your-bucket-name

# Download images
aws s3 cp s3://your-bucket-name/nextwork-denzel-awesome.png /tmp/
aws s3 cp s3://your-bucket-name/nextwork-lelo-awesome.png /tmp/

# Upload test file
echo "Test upload" > /tmp/test.txt
aws s3 cp /tmp/test.txt s3://your-bucket-name/test-uploads/

# Verify upload
aws s3 ls s3://your-bucket-name/test-uploads/
```

## 📈 **Terraform Outputs**

After successful deployment, you'll see:

```
Outputs:

iam_role_name = "nextwork-vpc-ec2-s3-role"
instance_profile_name = "nextwork-vpc-ec2-s3-profile"
s3_bucket_arn = "arn:aws:s3:::nextwork-vpc-s3-demo-bucket-xxxxxxxx"
s3_bucket_name = "nextwork-vpc-s3-demo-bucket-xxxxxxxx"
uploaded_images = {
  "nextwork_denzel_image" = "nextwork-denzel-awesome.png"
  "nextwork_lelo_image" = "nextwork-lelo-awesome.png"
}
vpc_id = "vpc-xxxxxxxxx"
vpc_public_instance_ip = "x.x.x.x"

connection_instructions = <<EOT
=== S3 Access Test Instructions ===

1. Connect to the EC2 instance using EC2 connect

2. Run the S3 access test script:
   ./test-s3-access.sh

3. Manual AWS CLI commands to test:
   aws s3 ls                                         # List all buckets
   aws s3 ls s3://bucket-name                        # List bucket contents
   aws s3 cp s3://bucket-name/nextwork-denzel-awesome.png /tmp/
   aws s3 cp s3://bucket-name/nextwork-lelo-awesome.png /tmp/
EOT
```

## 🧹 **Cleanup**

To destroy the infrastructure:

```bash
terraform destroy
```

**Note**: This will permanently delete the S3 bucket and all contents.

## 💡 **Learning Outcomes**

This project demonstrates:

- **IAM Best Practices**: Using roles instead of access keys
- **VPC Security**: Proper subnet and security group configuration
- **S3 Integration**: Seamless cloud storage access from compute
- **Infrastructure as Code**: Complete environment automation
- **Access Testing**: Comprehensive validation scripts

## 🎓 **AWS Solutions Architect Relevance**

### **Exam Topics Covered**
- **Storage Services**: S3 bucket configuration and security
- **Identity and Access Management**: IAM roles and instance profiles
- **VPC Networking**: Public subnet and internet gateway setup
- **Security**: Least-privilege access and encryption
- **Compute Services**: EC2 instance configuration with IAM integration

### **Real-World Applications**
- **Web Applications**: Serving static content from S3
- **Data Processing**: ETL jobs accessing S3 data lakes
- **Content Management**: Media storage and retrieval systems
- **Backup Solutions**: Automated backup to S3 storage
- **Analytics**: Log file processing and storage

## ✅ **Project Success Validation**

### **Infrastructure Checklist**
- ✅ VPC and public subnet created
- ✅ EC2 instance with public IP
- ✅ S3 bucket with unique name
- ✅ IAM role and instance profile attached
- ✅ NextWork images uploaded successfully
- ✅ Security groups properly configured

### **Functional Testing**
- ✅ EC2 instance can list S3 buckets
- ✅ Can download images from S3
- ✅ Can upload files to S3
- ✅ No hardcoded credentials required
- ✅ All operations use IAM role

This project showcases enterprise-ready patterns for secure cloud storage access, combining AWS best practices with practical implementation and comprehensive testing! 🚀