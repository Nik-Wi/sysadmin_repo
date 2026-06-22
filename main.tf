terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = ">= 0.70.0"
    }
  }
}

provider "yandex" {
  folder_id = "b1gevugr7qrknlemfiuh"
  cloud_id  = "b1g91msago27lee887ah"
  zone      = "ru-central1-b"
}

data "yandex_compute_image" "ubuntu" {
  family = "ubuntu-2204-lts"
}

resource "yandex_compute_instance" "vm" {
  count       = 3
  name        = "node-${count.index + 1}"
  hostname    = "node-${count.index + 1}"
  platform_id = "standard-v3"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
    }
  }

  network_interface {
    subnet_id = "e2ltjd6f0pt20otjsdpd"
    nat       = true
  }

  metadata = {
    ssh-keys = "nik_admin:${file("~/.ssh/id_ed25519.pub")}"
  }
}

output "vm_ips" {
  value = {
    for vm in yandex_compute_instance.vm :
    vm.name => vm.network_interface[0].nat_ip_address
  }
}
