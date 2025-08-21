# Private Subnet (private subnet + route table + NACL)

This folder contains the Terraform configuration used to create a private subnet inside an existing VPC and the network controls that protect it:

- a private subnet (no direct internet route)
- a dedicated private route table
- a network ACL (NACL) attached to the private subnet
- data sources used to discover available Availability Zones

Files
- `main.tf` — resources for the private subnet, private route table, NACL rules and associations.
- `variables.tf` — inputs you can change (VPC ID, subnet CIDR, AZ selection, NACL rule numbers, etc.).
- `data.tf` — data sources (for example `aws_availability_zones`) used to pick AZs dynamically.
- `provider.tf` — AWS provider configuration for this module.
- `outputs.tf` — exported values such as subnet id, route table id, and network ACL id.
- `README.md` — this document.

Quick overview

- Private subnet: created with a CIDR block that is routable only within the VPC. It is not associated with a route to an Internet Gateway.
- Private route table: separate from public route table; controls routing for the private subnet.
- Network ACL: stateless subnet-level ACL that permits/denies traffic. Use unique rule numbers and valid protocol/port values (protocol `-1` = all, and ports must be omitted when protocol is `-1`).

Important implementation notes

- Avoid duplicate NACL rule numbers. Each `aws_network_acl_rule` must use a unique `rule_number` for the same NACL and direction (ingress/egress).
- For `protocol = "-1"` (all protocols) you must not provide `from_port`/`to_port` values; providing ports with `-1` causes API errors.
- Use the `aws_availability_zones` data source and index into `data.aws_availability_zones.available.names` to select an AZ deterministically (e.g. `names[0]`).

Usage (local)

1. Initialize terraform:

```bash
terraform init
```

2. Review the plan:

```bash
terraform plan
```

3. Apply:

```bash
terraform apply
```

Outputs

- `private_subnet_id` — the created private subnet id.
- `private_route_table_id` — route table id associated with the private subnet.
- `private_network_acl_id` — the network ACL id attached to the subnet.

Clean up / Deletion

Delete with `terraform destroy` in this module once you no longer need the resources. If you delete the parent VPC manually, ensure dependent resources are removed in the correct order (detach and delete IGWs, delete subnets, then delete the VPC).

Exam relevance (Solutions Architect – Associate)

- Understand differences between public and private subnets and why private subnets are used for back-end resources.
- Know how route tables and NACLs interact with subnets and security groups.
- Know the limitations of NACLs (stateless) vs Security Groups (stateful).
- Practice provisioning network resources with Terraform to reinforce exam concepts and real-world automation.

Troubleshooting tips

- If you see errors like `NetworkAclEntryAlreadyExists`, check for duplicate `rule_number` values and for existing NACL entries in the AWS console.
- If you see `port (-1) out of range` or similar when creating NACL entries, set `protocol = "-1"` and omit `from_port`/`to_port`, or set protocol to a specific protocol and valid port range.

If you'd like, I can also:
- add example variable values in `variables.tf` and a `examples/` directory, or
- split this module into a reusable Terraform module with documented inputs/outputs.

- **Other Networking Components**: May include NAT gateways, VPN connections, or VPC endpoints, depending on configuration.

## Customization
- Variables allow you to specify CIDR blocks, allowed IP ranges, port access, and other security settings.
- You can define custom rules for security groups and network ACLs to meet your application's requirements.

## Outputs
After deployment, key information such as security group IDs, route table IDs, and network ACL IDs will be displayed, as defined in `outputs.tf`.

---
For further customization or details, review the individual `.tf` files in this directory.
