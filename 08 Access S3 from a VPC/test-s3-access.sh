#!/bin/bash

echo "=== S3 Access Test Script ==="
echo "Testing S3 access from EC2 instance with IAM role"
echo

# Get bucket name from terraform output (if available)
BUCKET_NAME=$(terraform output -raw s3_bucket_name 2>/dev/null || echo "your-bucket-name-here")

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

# Test 3: List images folder
echo "3. Testing images folder listing..."
aws s3 ls s3://$BUCKET_NAME/ --recursive
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

# Test 5: Try to upload a test file
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

# Test 6: Check IAM role information
echo "7. Current IAM role information..."
curl -s http://169.254.169.254/latest/meta-data/iam/security-credentials/
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
