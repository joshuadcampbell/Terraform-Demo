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
