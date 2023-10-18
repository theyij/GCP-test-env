

# Create 2 custom VPCs , setting routing mode regional

resource "google_compute_network" "vpc1" {
  name = "peer-a"
  auto_create_subnetworks = false
  routing_mode = "REGIONAL"
}


resource "google_compute_network" "vpc2" {
  name = "peer-b"
  auto_create_subnetworks = false
  routing_mode = "REGIONAL"
}



# Create a subnet in each of the custom VPC

resource "google_compute_subnetwork" "subnet1" {
  name          = "apac"
  ip_cidr_range = "10.0.1.0/24"
  region        = "asia-east1"
  network       = google_compute_network.vpc1.id
}

resource "google_compute_subnetwork" "subnet2" {
  name          = "amer"
  ip_cidr_range = "10.0.2.0/24"
  region        = "asia-east1"
  network       = google_compute_network.vpc2.id
}


# Provision peering from both VPC

resource "google_compute_network_peering" "peering1" {
  name         = "peering1"
  network      = google_compute_network.vpc1.self_link
  peer_network = google_compute_network.vpc2.self_link
}

resource "google_compute_network_peering" "peering2" {
  name         = "peering2"
  network      = google_compute_network.vpc2.self_link
  peer_network = google_compute_network.vpc1.self_link
}


# ================================
# Provision VM in each VPC

resource "google_compute_instance" "vm1" {
  name         = "tf-vm1"
  machine_type = "n1-standard-1"
  zone         = "asia-east1-a"

  tags = ["tf", "allow"]
  
  boot_disk {
    initialize_params {
      image = "centos-stream-9"
    }
  }

  network_interface {
    network = google_compute_network.vpc1.id
    subnetwork = google_compute_subnetwork.subnet1.id

    access_config {
      nat_ip = ""
    }
  }


  # metadata_startup_script {}

}

resource "google_compute_instance" "vm2" {
  name         = "tf-vm2"
  machine_type = "n1-standard-1"
  zone         = "asia-east1-a"

  tags = ["tf", "allow"]
  
  boot_disk {
    initialize_params {
      image = "centos-stream-9"
    }
  }

  network_interface {
    network = google_compute_network.vpc2.id
    subnetwork = google_compute_subnetwork.subnet2.id

    access_config {
      nat_ip = ""
    }    
  }
}

# Create firewall rules to allow traffic between peer

resource "google_compute_firewall" "peering-fw1" {
  name    = "tf-fw1"
  network = google_compute_network.vpc2.id

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
  network = google_compute_network.vpc1.id

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
