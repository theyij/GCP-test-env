# GCP-test-env
Setup test environment in GCP using Terraform


## Folder List

### peering-vpc
Provision VPC peering, create testing VM and Firewall rules to allow traffic.

1. The setup provision 2 custom VPCs with one subnet per each.
2. Provision peering connection from both VPCs.
3. Provision a VM instance in each VPC.
4. Create Firewall rules to allow ingress traffic from peer.


### ha-vpn
Provision HA VPN in 2 custom GCP VPCs. 2 Routers and 2 interface each, 4 tunnels and BPG session in total. 

1. Provisioning customer VPCs and 4 subnets to achieve HA setup, flow log enabled.
2. Provision VPN gateway and Cloud Router resources
3. Provisioning 4 VPN tunnels on the 2 interfaces on each Cloud Router
4. Provision BGP sessions on the created 4 VPN tunnels
5. Create 1 VM without external IP in each VPC, total 2 VMs.
6. Create Firewall rule on each side to allow ingress from specific ports

