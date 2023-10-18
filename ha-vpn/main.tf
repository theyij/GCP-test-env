# Provisioning customer VPCs and 4 subnets to achieve HA setup

resource "google_compute_network" "test-vpc1" {
  name                    = "test-vpc1"
  routing_mode            = "GLOBAL"
  auto_create_subnetworks = false
}

resource "google_compute_network" "test-vpc2" {
  name                    = "test-vpc2"
  routing_mode            = "GLOBAL"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "test-vpc1_subnet1" {
  name          = "ha-vpn-subnet-1"
  ip_cidr_range = "172.16.1.0/24"
  region        = "asia-northeast1"
  network       = google_compute_network.test-vpc1.id

  # Enable flow log for troubleshooting purpose
  log_config {
    aggregation_interval = "INTERVAL_10_MIN"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }  
}

resource "google_compute_subnetwork" "test-vpc1_subnet2" {
  name          = "ha-vpn-subnet-2"
  ip_cidr_range = "172.16.2.0/24"
  region        = "us-west1"
  network       = google_compute_network.test-vpc1.id

  log_config {
    aggregation_interval = "INTERVAL_10_MIN"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_subnetwork" "test-vpc2_subnet1" {
  name          = "ha-vpn-subnet-3"
  ip_cidr_range = "192.168.1.0/24"
  region        = "asia-northeast1"
  network       = google_compute_network.test-vpc2.id

  log_config {
    aggregation_interval = "INTERVAL_10_MIN"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_subnetwork" "test-vpc2_subnet2" {
  name          = "ha-vpn-subnet-4"
  ip_cidr_range = "192.168.2.0/24"
  region        = "us-east1"
  network       = google_compute_network.test-vpc2.id

  log_config {
    aggregation_interval = "INTERVAL_10_MIN"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}



# Provision VPN gateway and Cloud Router resources

resource "google_compute_ha_vpn_gateway" "ha_gateway1" {
  region  = "asia-northeast1"
  name    = "ha-vpn-1"
  network = google_compute_network.test-vpc1.id
}

resource "google_compute_ha_vpn_gateway" "ha_gateway2" {
  region  = "asia-northeast1"
  name    = "ha-vpn-2"
  network = google_compute_network.test-vpc2.id
}



resource "google_compute_router" "router1" {
  name    = "ha-vpn-router1"
  region  = "asia-northeast1"
  network = google_compute_network.test-vpc1.name
  bgp {
    asn = 64514
  }
}

resource "google_compute_router" "router2" {
  name    = "ha-vpn-router2"
  region  = "asia-northeast1"
  network = google_compute_network.test-vpc2.name
  bgp {
    asn = 64515
  }
}


# Provisioning 4 VPN tunnels on the 2 interfaces on each Cloud Router


resource "google_compute_vpn_tunnel" "tunnel1" {
  name                  = "ha-vpn-tunnel1"
  region                = "asia-northeast1"
  vpn_gateway           = google_compute_ha_vpn_gateway.ha_gateway1.id
  peer_gcp_gateway      = google_compute_ha_vpn_gateway.ha_gateway2.id
  shared_secret         = "something secret"
  router                = google_compute_router.router1.id
  vpn_gateway_interface = 0
}

resource "google_compute_vpn_tunnel" "tunnel2" {
  name                  = "ha-vpn-tunnel2"
  region                = "asia-northeast1"
  vpn_gateway           = google_compute_ha_vpn_gateway.ha_gateway1.id
  peer_gcp_gateway      = google_compute_ha_vpn_gateway.ha_gateway2.id
  shared_secret         = "something secret"
  router                = google_compute_router.router1.id
  vpn_gateway_interface = 1
}

resource "google_compute_vpn_tunnel" "tunnel3" {
  name                  = "ha-vpn-tunnel3"
  region                = "asia-northeast1"
  vpn_gateway           = google_compute_ha_vpn_gateway.ha_gateway2.id
  peer_gcp_gateway      = google_compute_ha_vpn_gateway.ha_gateway1.id
  shared_secret         = "something secret"
  router                = google_compute_router.router2.id
  vpn_gateway_interface = 0
}

resource "google_compute_vpn_tunnel" "tunnel4" {
  name                  = "ha-vpn-tunnel4"
  region                = "asia-northeast1"
  vpn_gateway           = google_compute_ha_vpn_gateway.ha_gateway2.id
  peer_gcp_gateway      = google_compute_ha_vpn_gateway.ha_gateway1.id
  shared_secret         = "something secret"
  router                = google_compute_router.router2.id
  vpn_gateway_interface = 1
}


# Provision BGP sessions on the created 4 VPN tunnels

resource "google_compute_router_interface" "router1_interface1" {
  name       = "router1-interface1"
  router     = google_compute_router.router1.name
  region     = "asia-northeast1"
  ip_range   = "169.254.0.1/30"
  vpn_tunnel = google_compute_vpn_tunnel.tunnel1.name
}

resource "google_compute_router_peer" "router1_peer1" {
  name                      = "router1-peer1"
  router                    = google_compute_router.router1.name
  region                    = "asia-northeast1"
  peer_ip_address           = "169.254.0.2"
  peer_asn                  = 64515
  advertised_route_priority = 100
  interface                 = google_compute_router_interface.router1_interface1.name
}

resource "google_compute_router_interface" "router1_interface2" {
  name       = "router1-interface2"
  router     = google_compute_router.router1.name
  region     = "asia-northeast1"
  ip_range   = "169.254.1.2/30"
  vpn_tunnel = google_compute_vpn_tunnel.tunnel2.name
}

resource "google_compute_router_peer" "router1_peer2" {
  name                      = "router1-peer2"
  router                    = google_compute_router.router1.name
  region                    = "asia-northeast1"
  peer_ip_address           = "169.254.1.1"
  peer_asn                  = 64515
  advertised_route_priority = 100
  interface                 = google_compute_router_interface.router1_interface2.name
}

resource "google_compute_router_interface" "router2_interface1" {
  name       = "router2-interface1"
  router     = google_compute_router.router2.name
  region     = "asia-northeast1"
  ip_range   = "169.254.0.2/30"
  vpn_tunnel = google_compute_vpn_tunnel.tunnel3.name
}

resource "google_compute_router_peer" "router2_peer1" {
  name                      = "router2-peer1"
  router                    = google_compute_router.router2.name
  region                    = "asia-northeast1"
  peer_ip_address           = "169.254.0.1"
  peer_asn                  = 64514
  advertised_route_priority = 100
  interface                 = google_compute_router_interface.router2_interface1.name
}

resource "google_compute_router_interface" "router2_interface2" {
  name       = "router2-interface2"
  router     = google_compute_router.router2.name
  region     = "asia-northeast1"
  ip_range   = "169.254.1.1/30"
  vpn_tunnel = google_compute_vpn_tunnel.tunnel4.name
}

resource "google_compute_router_peer" "router2_peer2" {
  name                      = "router2-peer2"
  router                    = google_compute_router.router2.name
  region                    = "asia-northeast1"
  peer_ip_address           = "169.254.1.2"
  peer_asn                  = 64514
  advertised_route_priority = 100
  interface                 = google_compute_router_interface.router2_interface2.name
}


# Provision VM in each VPC

resource "google_compute_instance" "vm1" {
  name         = "tf-vm1"
  machine_type = "n1-standard-1"
  zone         = "asia-northeast1-a"

  tags = ["tf", "allow"]
  
  boot_disk {
    initialize_params {
      image = "centos-stream-9"
    }
  }

  network_interface {
    network = google_compute_network.test-vpc1.id
    subnetwork = google_compute_subnetwork.test-vpc1_subnet1.id

    # access_config {
    #   nat_ip = ""
    # }
  }


  # metadata_startup_script {}

}

resource "google_compute_instance" "vm2" {
  name         = "tf-vm2"
  machine_type = "n1-standard-1"
  zone         = "asia-northeast1-b"

  tags = ["tf", "allow"]
  
  boot_disk {
    initialize_params {
      image = "centos-stream-9"
    }
  }

  network_interface {
    network = google_compute_network.test-vpc2.id
    subnetwork = google_compute_subnetwork.test-vpc2_subnet1.id

    #access_config {
        # nat_ip = ""
    #}    
  }
}

# Create firewall rules to allow traffic between VPCs

resource "google_compute_firewall" "peering-fw1" {
  name    = "tf-fw1"
  network = google_compute_network.test-vpc2.id

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["80", "8080", "1000-2000"]
  }

  source_ranges = ["0.0.0.0/0"]
  # target_tags = ["allow"]
}

resource "google_compute_firewall" "peering-fw2" {
  name    = "tf-fw2"
  network = google_compute_network.test-vpc1.id

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["80", "8080", "1000-2000"]
  }

  source_ranges = ["0.0.0.0/0"]
  # target_tags = ["allow"]
}
