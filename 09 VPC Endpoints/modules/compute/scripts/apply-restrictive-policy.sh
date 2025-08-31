#!/bin/bash

# Script to apply restrictive S3 bucket policy that only allows VPC endpoint access
# This script should be run after terraform apply to secure the bucket

BUCKET_NAME="$1"
VPC_ENDPOINT_ID="$2"

if [ -z "$BUCKET_NAME" ] || [ -z "$VPC_ENDPOINT_ID" ]; then
    echo "Usage: $0 <bucket-name> <vpc-endpoint-id>"
    echo "Example: $0 nextwork-vpc-s3-demo-bucket-ac2uxc04 vpce-08a15c02bd8e0412d"
    exit 1
fi

echo "Applying restrictive bucket policy to: $BUCKET_NAME"
echo "VPC Endpoint ID: $VPC_ENDPOINT_ID"

# Create the restrictive policy
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

# Apply the policy
aws s3api put-bucket-policy --bucket "$BUCKET_NAME" --policy "$POLICY"

if [ $? -eq 0 ]; then
    echo "✅ Restrictive bucket policy applied successfully!"
    echo "The bucket now only allows access through VPC endpoint: $VPC_ENDPOINT_ID"
else
    echo "❌ Failed to apply bucket policy"
    exit 1
fi
