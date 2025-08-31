#!/bin/bash

# Test script to verify S3 access through VPC endpoint
# This script tests both object operations and demonstrates the VPC endpoint restriction

BUCKET_NAME="$1"
TEST_FILE="/tmp/vpc-test-file.txt"

if [ -z "$BUCKET_NAME" ]; then
    echo "Usage: $0 <bucket-name>"
    echo "Example: $0 nextwork-vpc-s3-demo-bucket-ac2uxc04"
    exit 1
fi

echo "Testing S3 access through VPC endpoint..."
echo "Bucket: $BUCKET_NAME"
echo "========================================="

# Create a test file
echo "Hello from VPC Endpoint $(date)" > $TEST_FILE

echo "1. Testing bucket listing..."
aws s3 ls s3://$BUCKET_NAME/

echo -e "\n2. Testing file upload..."
aws s3 cp $TEST_FILE s3://$BUCKET_NAME/vpc-test.txt

echo -e "\n3. Testing file download..."
aws s3 cp s3://$BUCKET_NAME/vpc-test.txt /tmp/downloaded-test.txt

echo -e "\n4. Verifying downloaded content..."
cat /tmp/downloaded-test.txt

echo -e "\n5. Testing existing objects..."
echo "Listing existing objects:"
aws s3 ls s3://$BUCKET_NAME/ --recursive

echo -e "\n6. Attempting to download existing image..."
aws s3 cp s3://$BUCKET_NAME/nextwork-denzel-awesome.png /tmp/ 2>/dev/null && echo "✅ Successfully downloaded image" || echo "❌ Failed to download image"

echo -e "\n✅ VPC Endpoint access test completed!"

# Clean up
rm -f $TEST_FILE /tmp/downloaded-test.txt
