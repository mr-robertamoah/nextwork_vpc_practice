#!/bin/bash

# Script to remove S3 bucket policy to allow Terraform destruction
# This script should be run before terraform destroy

BUCKET_NAME="$1"

if [ -z "$BUCKET_NAME" ]; then
    echo "Usage: $0 <bucket-name>"
    echo "Example: $0 nextwork-vpc-s3-demo-bucket-ac2uxc04"
    exit 1
fi

echo "Removing bucket policy from: $BUCKET_NAME"

# Remove the bucket policy
aws s3api delete-bucket-policy --bucket "$BUCKET_NAME"

if [ $? -eq 0 ]; then
    echo "✅ Bucket policy removed successfully!"
    echo "You can now run: terraform destroy"
else
    echo "❌ Failed to remove bucket policy"
    exit 1
fi
