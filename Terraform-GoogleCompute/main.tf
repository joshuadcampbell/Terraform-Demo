// Provider for this terraform build

provider "google" {
  credentials = "${var.credentials}"
  region      = "${var.region}"
  project     = "${var.gcp_project}"
  zone        = "${var.zone}"
}

// Create VPC 

resource "google_compute_network" "vpc" {
  name                    = "${var.name}-vpc"
  auto_create_subnetworks = "false"
}

// Create Subnet 

resource "google_compute_subnetwork" "subnet" {
  name          = "${var.name}-subnet"
  ip_cidr_range = "${var.subnet_cidr}"
  network       = "${var.name}-vpc"
  depends_on    = ["google_compute_network.vpc"]
  region        = "${var.region}"
}

// VPC Firewall Configuration

resource "google_compute_firewall" "firewall" {
  name    = "${var.name}-firewall"
  network = "${google_compute_network.vpc.name}"

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22", "80"]
  }
}

// Create Instance

resource "google_compute_instance" "instance" {
  name         = "${var.name}-instance"
  machine_type = "f1-micro"

  boot_disk {
    initialize_params {
      image = "centos-cloud/centos-7"
    }
  }

  depends_on = ["google_compute_subnetwork.subnet"]

  network_interface {
    subnetwork    = "${var.name}-subnet"
    access_config = {}
  }

  connection {
    user        = "jcampbell"
    type        = "ssh"
    private_key = "${file(var.ssh_key)}"
    timeout     = "2m"
  }

  provisioner "remote-exec" {
    inline = [
      "export PATH=$PATH:/usr/bin",
      "sudo yum -y update",
      "sudo yum -y install nginx git",
      "sudo systemctl enable nginx && sudo systemctl start nginx",
      "cd /usr/share/nginx && sudo rm -rf html",
      "sudo git clone https://github.com/joshuadcampbell/joshuadcampbell.com.git html",
    ]
  }
}

output "ip" {
  value = "${google_compute_instance.instance.network_interface.0.access_config.0.nat_ip}"
}
