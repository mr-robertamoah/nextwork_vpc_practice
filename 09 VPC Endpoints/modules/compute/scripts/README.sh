#!/bin/bash

# Quick reference guide for managing S3 bucket policies with VPC endpoints

cat << 'EOF'
==================================================
VPC Endpoint S3 Management Scripts
==================================================

📋 Available Scripts:
-------------------

1. test-vpc-endpoint-access.sh
   Purpose: Test S3 access through VPC endpoint
   Usage: ./test-vpc-endpoint-access.sh <bucket-name>
   
2. apply-restrictive-policy.sh  
   Purpose: Apply restrictive policy (VPC endpoint only access)
   Usage: ./apply-restrictive-policy.sh <bucket-name> <vpc-endpoint-id>
   
3. remove-bucket-policy.sh
   Purpose: Remove bucket policy (for Terraform destruction)
   Usage: ./remove-bucket-policy.sh <bucket-name>

🔄 Typical Workflow:
------------------

Development Phase:
1. Deploy infrastructure: terraform apply
2. Apply restrictive policy: ./apply-restrictive-policy.sh <bucket> <endpoint>
3. Test functionality: ./test-vpc-endpoint-access.sh <bucket>

Destruction Phase:
1. Remove restrictive policy: ./remove-bucket-policy.sh <bucket>
2. Destroy infrastructure: terraform destroy

📝 Current Environment Values:
-----------------------------
EOF

echo "Bucket Name: $(terraform output -raw s3_bucket_name 2>/dev/null || echo 'Run terraform output to get bucket name')"
echo "VPC Endpoint ID: $(terraform output -raw vpc_endpoint_id 2>/dev/null || echo 'Run terraform output to get endpoint ID')"

cat << 'EOF'

💡 Tips:
-------
- Always test VPC endpoint access after applying restrictive policies
- Remove bucket policies before running terraform destroy
- Scripts require AWS CLI to be configured with appropriate permissions
- EC2 instance should have IAM role with S3 and IAM permissions

EOF
