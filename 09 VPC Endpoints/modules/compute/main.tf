# Create EC2 instance in public subnet
resource "aws_instance" "public" {
  ami                         = data.aws_ami.latest.id
  instance_type               = var.instance_type
  subnet_id                   = var.public_subnet_id
  security_groups             = [var.public_security_group_id]
  associate_public_ip_address = true
  iam_instance_profile        = var.iam_instance_profile

  # User data to install AWS CLI and create management scripts
  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y aws-cli

    # Create original S3 test script
    cat > /home/ec2-user/test-s3-access.sh << 'ORIGINALSCRIPT'
#!/bin/bash

echo "=== S3 Access Test Script ==="
echo "Testing S3 access from EC2 instance with IAM role"
echo

# Get bucket name from available buckets
BUCKET_NAME=$(aws s3 ls | grep nextwork-vpc-s3-demo-bucket | awk '{print $3}' | head -n1)
echo "Bucket Name: $BUCKET_NAME"
echo

# Test 1: List all S3 buckets
echo "1. Testing bucket listing permissions..."
aws s3 ls
if [ $? -eq 0 ]; then
    echo "✅ SUCCESS: Can list S3 buckets"
else
    echo "❌ FAILED: Cannot list S3 buckets"
fi
echo

# Test 2: List bucket contents
echo "2. Testing bucket content listing..."
aws s3 ls s3://$BUCKET_NAME
if [ $? -eq 0 ]; then
    echo "✅ SUCCESS: Can list bucket contents"
else
    echo "❌ FAILED: Cannot list bucket contents"
fi
echo

# Test 3: List all objects recursively
echo "3. Testing recursive object listing..."
aws s3 ls s3://$BUCKET_NAME --recursive
if [ $? -eq 0 ]; then
    echo "✅ SUCCESS: Can list all objects recursively"
else
    echo "❌ FAILED: Cannot list objects recursively"
fi
echo

# Test 4: Download NextWork images
echo "4. Testing image download (Denzel image)..."
aws s3 cp s3://$BUCKET_NAME/nextwork-denzel-awesome.png /tmp/denzel-test.png
if [ $? -eq 0 ]; then
    echo "✅ SUCCESS: Downloaded Denzel image"
    ls -la /tmp/denzel-test.png
else
    echo "❌ FAILED: Cannot download Denzel image"
fi
echo

echo "5. Testing image download (Lelo image)..."
aws s3 cp s3://$BUCKET_NAME/nextwork-lelo-awesome.png /tmp/lelo-test.png
if [ $? -eq 0 ]; then
    echo "✅ SUCCESS: Downloaded Lelo image"
    ls -la /tmp/lelo-test.png
else
    echo "❌ FAILED: Cannot download Lelo image"
fi
echo

# Test 6: Try to upload a test file
echo "6. Testing upload permissions..."
echo "Test file created on $(date)" > /tmp/test-upload.txt
aws s3 cp /tmp/test-upload.txt s3://$BUCKET_NAME/test-uploads/
if [ $? -eq 0 ]; then
    echo "✅ SUCCESS: Can upload files to bucket"
    # Clean up
    aws s3 rm s3://$BUCKET_NAME/test-uploads/test-upload.txt
    echo "   (Test file cleaned up)"
else
    echo "❌ FAILED: Cannot upload files to bucket"
fi
echo

# Test 7: Check IAM role information
echo "7. Current IAM role information..."
curl -s http://169.254.169.254/latest/meta-data/iam/security-credentials/
echo
echo

echo "=== Test Summary ==="
echo "If all tests show ✅ SUCCESS, your S3 access is working correctly!"
echo "The EC2 instance can:"
echo "  - List S3 buckets"
echo "  - Read objects from the bucket"
echo "  - Upload objects to the bucket"
echo
echo "NextWork Images Available:"
echo "  - nextwork-denzel-awesome.png"
echo "  - nextwork-lelo-awesome.png"
echo
ORIGINALSCRIPT

    # Create VPC endpoint management scripts directory
    mkdir -p /home/ec2-user/vpc-management
    
    # Script to test VPC endpoint access
    cat > /home/ec2-user/vpc-management/test-vpc-endpoint-access.sh << 'VPCSCRIPT'
#!/bin/bash
BUCKET_NAME="$1"
TEST_FILE="/tmp/vpc-test-file.txt"

if [ -z "$BUCKET_NAME" ]; then
    echo "Usage: $0 <bucket-name>"
    exit 1
fi

echo "Testing S3 access through VPC endpoint..."
echo "Bucket: $BUCKET_NAME"
echo "========================================="

echo "Hello from VPC Endpoint $(date)" > $TEST_FILE

echo "1. Testing bucket listing..."
aws s3 ls s3://$BUCKET_NAME/

echo -e "\n2. Testing file upload..."
aws s3 cp $TEST_FILE s3://$BUCKET_NAME/vpc-test.txt

echo -e "\n3. Testing file download..."
aws s3 cp s3://$BUCKET_NAME/vpc-test.txt /tmp/downloaded-test.txt

echo -e "\n4. Verifying downloaded content..."
cat /tmp/downloaded-test.txt

echo -e "\n✅ VPC Endpoint access test completed!"
rm -f $TEST_FILE /tmp/downloaded-test.txt
VPCSCRIPT

    # Script to remove bucket policy for Terraform destruction
    cat > /home/ec2-user/vpc-management/remove-bucket-policy.sh << 'REMOVESCRIPT'
#!/bin/bash
BUCKET_NAME="$1"

if [ -z "$BUCKET_NAME" ]; then
    echo "Usage: $0 <bucket-name>"
    exit 1
fi

echo "Removing bucket policy from: $BUCKET_NAME"
aws s3api delete-bucket-policy --bucket "$BUCKET_NAME"

if [ $? -eq 0 ]; then
    echo "✅ Bucket policy removed successfully!"
    echo "You can now run: terraform destroy"
else
    echo "❌ Failed to remove bucket policy"
    exit 1
fi
REMOVESCRIPT

    # Script to apply restrictive policy
    cat > /home/ec2-user/vpc-management/apply-restrictive-policy.sh << 'APPLYSCRIPT'
#!/bin/bash
BUCKET_NAME="$1"
VPC_ENDPOINT_ID="$2"

if [ -z "$BUCKET_NAME" ] || [ -z "$VPC_ENDPOINT_ID" ]; then
    echo "Usage: $0 <bucket-name> <vpc-endpoint-id>"
    exit 1
fi

echo "Applying restrictive bucket policy to: $BUCKET_NAME"
echo "VPC Endpoint ID: $VPC_ENDPOINT_ID"

POLICY='{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "VPCEndpointAccessOnly",
      "Effect": "Allow",
      "Principal": "*",
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::'$BUCKET_NAME'",
        "arn:aws:s3:::'$BUCKET_NAME'/*"
      ],
      "Condition": {
        "StringEquals": {
          "aws:sourceVpce": "'$VPC_ENDPOINT_ID'"
        }
      }
    },
    {
      "Sid": "DenyNonVPCEndpointAccess",
      "Effect": "Deny",
      "Principal": "*",
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject"
      ],
      "Resource": "arn:aws:s3:::'$BUCKET_NAME'/*",
      "Condition": {
        "StringNotEquals": {
          "aws:sourceVpce": "'$VPC_ENDPOINT_ID'"
        }
      }
    }
  ]
}'

aws s3api put-bucket-policy --bucket "$BUCKET_NAME" --policy "$POLICY"

if [ $? -eq 0 ]; then
    echo "✅ Restrictive bucket policy applied successfully!"
    echo "The bucket now only allows access through VPC endpoint: $VPC_ENDPOINT_ID"
else
    echo "❌ Failed to apply bucket policy"
    exit 1
fi
APPLYSCRIPT

    # README script with usage instructions
    cat > /home/ec2-user/vpc-management/README.sh << 'READMESCRIPT'
#!/bin/bash

echo "=============================================="
echo "VPC Endpoint S3 Management Scripts"
echo "=============================================="
echo
echo "Available Scripts:"
echo "1. test-vpc-endpoint-access.sh - Test S3 access through VPC endpoint"
echo "2. apply-restrictive-policy.sh - Apply restrictive policy (VPC endpoint only)"
echo "3. remove-bucket-policy.sh - Remove bucket policy (for Terraform destruction)"
echo
echo "Typical Workflow:"
echo "Development Phase:"
echo "1. Deploy infrastructure: terraform apply"
echo "2. Apply restrictive policy: ./apply-restrictive-policy.sh <bucket> <endpoint>"
echo "3. Test functionality: ./test-vpc-endpoint-access.sh <bucket>"
echo
echo "Destruction Phase:"
echo "1. Remove restrictive policy: ./remove-bucket-policy.sh <bucket>"
echo "2. Destroy infrastructure: terraform destroy"
echo
echo "Get bucket name: terraform output s3_bucket_name"
echo "Get VPC endpoint ID: terraform output vpc_endpoint_id"
READMESCRIPT

    # Make all scripts executable and set proper ownership
    chmod +x /home/ec2-user/test-s3-access.sh
    chmod +x /home/ec2-user/vpc-management/*.sh
    chown -R ec2-user:ec2-user /home/ec2-user/test-s3-access.sh
    chown -R ec2-user:ec2-user /home/ec2-user/vpc-management/
    
    echo "VPC Endpoint S3 management scripts installed" > /var/log/user-data.log
  EOF

  tags = merge(var.tags, {
    Name = "${var.vpc_name}-public-ec2"
  })
}
