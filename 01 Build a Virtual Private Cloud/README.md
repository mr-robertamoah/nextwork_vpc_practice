# Virtual Private Cloud (VPC) Infrastructure Documentation

This directory contains Terraform configuration files to build a basic AWS Virtual Private Cloud (VPC) environment. Below is an overview of the resources and their purpose:

## Files
- `main.tf`: Defines the main infrastructure resources, including the VPC, subnets, and related networking components.
- `provider.tf`: Specifies the AWS provider and region for resource deployment.
- `variables.tf`: Declares input variables for customizing the infrastructure (e.g., VPC CIDR block, subnet CIDRs, etc.).
- `outputs.tf`: Defines output values to display useful information after deployment (e.g., VPC ID, subnet IDs).

## Resources Created
- **VPC**: A logically isolated section of the AWS Cloud where you can launch AWS resources in a virtual network.
- **Subnets**: Segments of the VPC's IP address range where resources can be placed. Subnets can be assigned to specific Availability Zones.
- **Internet Gateway**: Allows communication between resources in your VPC and the internet.
- **Route Tables**: Controls the routing of traffic within the VPC and to external networks.
- **Other Networking Components**: May include security groups, network ACLs, and more, depending on configuration.

## Customization
- You can customize the CIDR blocks, number of subnets, and their assignment to Availability Zones using variables in `variables.tf`.
- The configuration supports dynamic selection of available AWS Availability Zones for subnets.

## Usage
1. Initialize Terraform: `terraform init`
2. Review the plan: `terraform plan`
3. Apply the configuration: `terraform apply`

## Outputs
After deployment, useful information such as VPC ID and subnet IDs will be displayed, as defined in `outputs.tf`.

---
For further customization or details, review the individual `.tf` files in this directory.
