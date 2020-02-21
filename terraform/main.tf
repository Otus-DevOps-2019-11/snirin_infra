terraform {
  # Версия terraform
  required_version = "0.12.20"
}

provider "google" {
  # Версия провайдера
  version = "2.15"

  # ID проекта
  #project = "infra-265807"
  #region = "europe-west-1"

  project = var.project
  region  = var.region
}

resource "google_compute_instance" "app" {
  name         = "reddit-app"
  machine_type = "g1-small"
  zone         = var.zone
  tags         = ["reddit-app"]
  boot_disk {
    initialize_params {
      #image = "reddit-base"
      image = var.disk_image
    }
  }

  network_interface {
    network = "default"
    access_config {}
  }

  metadata = {
    # путь до публичного ключа
    #ssh-keys = "appuser:${file("~/.ssh/appuser.pub")}"
    ssh-keys = "appuser:${file(var.public_key_path)}"
  }

  connection {
    type  = "ssh"
    host  = self.network_interface[0].access_config[0].nat_ip
    user  = "appuser"
    agent = false
    # путь до приватного ключа
    #private_key = file("~/.ssh/appuser")
    private_key = file(var.private_key_path)
  }

  provisioner "file" {
    source      = "files/puma.service"
    destination = "/tmp/puma.service"
  }

  provisioner "remote-exec" {
    script = "files/deploy.sh"
  }
}

resource "google_compute_firewall" "firewall_puma" {
  name = "allow-puma-default"
  # Название сети, в которой действует правило
  network = "default"
  # Какой доступ разрешить
  allow {
    protocol = "tcp"
    ports    = ["9292"]
  }
  # Каким адресам разрешаем доступ
  source_ranges = ["0.0.0.0/0"]
  # Правило применимо для инстансов с перечисленными тэгами
  target_tags = ["reddit-app"]
}

resource "google_compute_project_metadata_item" "ssh-keys" {
  key   = "ssh-keys"
  value = <<EOF
  ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDXsiM/gv6CPEtu+7DDc3QDqbJrJ//Fg+Bk2b7mwrK9O7+s9PuKVK70kghJM7GE/ooMdclPL2SUMnsmOKGxOVakJbej1RM1HIyNPu+X3N1AWsIoaeG/sKnkhuDzizDNQXeEoX94NKPbOBC5pWVUk9p++0PLUAlFOpdERypKP//I71fRIe1EQrpB7VjDeTOEjOawrWGSNJUWkMjrFhyyD1ENqO2BRUXctGdZmsGcCpn1idhNgv59a7woJk632i0Y1hB8QdTVgarVVYczJCd7ObEICFZ1O+Lwa9CaVxClCRrKrOtMBpauVeJSRoIpJ9lNKcyV5dgCOf1MbFM7G+tiYMhb appuser1
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDXsiM/gv6CPEtu+7DDc3QDqbJrJ//Fg+Bk2b7mwrK9O7+s9PuKVK70kghJM7GE/ooMdclPL2SUMnsmOKGxOVakJbej1RM1HIyNPu+X3N1AWsIoaeG/sKnkhuDzizDNQXeEoX94NKPbOBC5pWVUk9p++0PLUAlFOpdERypKP//I71fRIe1EQrpB7VjDeTOEjOawrWGSNJUWkMjrFhyyD1ENqO2BRUXctGdZmsGcCpn1idhNgv59a7woJk632i0Y1hB8QdTVgarVVYczJCd7ObEICFZ1O+Lwa9CaVxClCRrKrOtMBpauVeJSRoIpJ9lNKcyV5dgCOf1MbFM7G+tiYMhb appuser2
  EOF
}
