resource "google_compute_instance" "db" {
  name         = "reddit-db-${var.env_type}"
  machine_type = "g1-small"
  zone         = var.zone
  tags         = ["reddit-db"]
  boot_disk {
    initialize_params {
      image = var.db_disk_image
    }
  }

  network_interface {
    network = "default"
    access_config {}
  }

  metadata = {
    ssh-keys = "appuser:${file(var.public_key_path)}"
  }

  depends_on = [var.modules_depends_on]

  connection {
    type        = "ssh"
    host        = self.network_interface[0].access_config[0].nat_ip
    user        = "appuser"
    agent       = false
    private_key = file(var.private_key_path)
  }

  provisioner "file" {
    source      = "${path.module}/files/mongod.conf"
    destination = var.use_provisioners ? "/tmp/mongod.conf" : "/dev/null"
  }

  provisioner "remote-exec" {
    inline = [var.use_provisioners ? "sudo mv /tmp/mongod.conf /etc/mongod.conf && sudo systemctl restart mongod" : "exit 0"]
  }
}

resource "google_compute_firewall" "firewall_mongo" {
  name    = "allow-mongo-${var.env_type}"
  network = "default"
  allow {
    protocol = "tcp"
    ports    = ["27017"]
  }
  target_tags = ["reddit-db"]
  #source_tags = ["reddit-app"]
}
