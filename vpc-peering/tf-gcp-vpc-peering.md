# Provision VPC peering, create testing VM and Firewall rules to allow traffic


## Objective

- Create a test environment for VPC peering for further troubleshooting or configuration testing.

1. The setup provision 2 custom VPCs with one subnet per each.
2. Provision peering connection from both VPCs.
3. Provision a VM instance in each VPC.
4. Create Firewall rules to allow ingress traffic from peer.




## Basic Terraform Commands

### Initialize Terraform in the directory where the main.tf is located

- $ terraform init
- $ terraform init -upgrade

### Review and verify the configuration that would be create or update by Terraform.

- $ terraform plan
- $ terraform apply

### Remove resources applied with Terraform

- $ terraform destroy
