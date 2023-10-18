# GCP-test-env
Setup test environment in GCP using Terraform


## Folder List

### peering-vpc
Provision VPC peering, create testing VM and Firewall rules to allow traffic.

1. The setup provision 2 custom VPCs with one subnet per each.
2. Provision peering connection from both VPCs.
3. Provision a VM instance in each VPC.
4. Create Firewall rules to allow ingress traffic from peer.
