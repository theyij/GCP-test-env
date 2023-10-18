# Provision HA VPN in 2 custom GCP VPCs. 2 Routers and 2 interface each, 4 tunnels and BPG session in total. 


## Objective

- Create a test environment for HA VPN for further troubleshooting or configuration testing.
- The setup can also help investigating on BPG session flap or Cloud Router related issus.

1. Provisioning customer VPCs and 4 subnets to achieve HA setup
2. Provision VPN gateway and Cloud Router resources
3. Provisioning 4 VPN tunnels on the 2 interfaces on each Cloud Router
4. Provision BGP sessions on the created 4 VPN tunnels

### Reference

https://cloud.google.com/network-connectivity/docs/vpn/how-to/automate-vpn-setup-with-terraform


## Basic Terraform Commands

### Initialize Terraform in the directory where the main.tf is located

- $ terraform init
- $ terraform init -upgrade

### Review and verify the configuration that would be create or update by Terraform.

- $ terraform plan
- $ terraform apply

### Remove resources applied with Terraform

- $ terraform destroy


