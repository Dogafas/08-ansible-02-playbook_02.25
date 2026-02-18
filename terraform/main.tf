terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "~> 0.100"
    }
  }
}

provider "yandex" {
  cloud_id                 = var.cloud_id
  folder_id                = var.folder_id
  zone                     = var.default_zone
  service_account_key_file = var.service_account_key_file
}

resource "yandex_compute_instance" "vm" {
  for_each = { for vm in var.each_vm : vm.name => vm }

  name        = each.value.name
  platform_id = each.value.platform_id

  resources {
    cores  = each.value.cores
    memory = each.value.memory
  }

  boot_disk {
    initialize_params {
      image_id = "fd80bm0rh4rkepi5ksdi"
      size     = each.value.disk_size
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.default.id
    nat       = true
  }

  metadata = {
    ssh-keys  = "yc-user:${file("/home/meteoguru/.ssh/yandex_vm.pub")}"
    user-data = <<EOF
#cloud-config
users:
  - name: yc-user
    sudo: ALL=(ALL) NOPASSWD:ALL
    shell: /bin/bash
    ssh_authorized_keys:
      - ${file("/home/meteoguru/.ssh/yandex_vm.pub")}
EOF
  }
}

resource "yandex_vpc_network" "default" {}

resource "yandex_vpc_subnet" "default" {
  name           = "default-subnet"
  zone           = var.default_zone
  network_id     = yandex_vpc_network.default.id
  v4_cidr_blocks = ["10.0.0.0/24"]
}

output "vm_ips" {
  value = {
    for name, vm in yandex_compute_instance.vm :
    name => vm.network_interface[0].nat_ip_address
  }
}
