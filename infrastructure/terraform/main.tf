
# 1. Создаем сеть
data "yandex_vpc_network" "vpc_main" {
  network_id = "enpnmavit2epvaj6nj8g"
}

# 2. Создаем три подсети в разных зонах (имена уникальны, CIDR не пересекаются)
resource "yandex_vpc_subnet" "subnet-d" {
  name           = "dns-subnet-d"
  zone           = "ru-central1-d"
  network_id = data.yandex_vpc_network.vpc_main.id
  v4_cidr_blocks = ["10.0.0.0/24"]
}

# resource "yandex_vpc_subnet" "subnet-a" {
#   name           = "dns-subnet-a"
#   zone           = "ru-central1-a"
#   network_id = data.yandex_vpc_network.vpc_main.id
#   v4_cidr_blocks = ["10.0.1.0/24"]
# }

resource "yandex_vpc_subnet" "subnet-e" {
  name           = "dns-subnet-e"
  zone           = "ru-central1-e"
  network_id = data.yandex_vpc_network.vpc_main.id
  v4_cidr_blocks = ["10.0.2.0/24"]
}

# 3. Группа безопасности (открываем SSH, HTTP, DNS)
resource "yandex_vpc_security_group" "sg1" {
  name       = "dns-server-sg"
  network_id = data.yandex_vpc_network.vpc_main.id

  ingress {
    protocol       = "TCP"
    description    = "SSH"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 22
  }
  ingress {
    protocol       = "TCP"
    description    = "HTTP"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 80
  }
  ingress {
    protocol       = "TCP"
    description    = "TCP DNS"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 53
  }
  ingress {
    protocol       = "UDP"
    description    = "UDP DNS"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 53
  }
  egress {
    protocol       = "ANY"
    description    = "outgoing"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

# 4. Виртуальные машины (жестко привязаны к своим подсетям)

# VM 1: Bind9 (Зона D)
resource "yandex_compute_instance" "bind_vm" {
  name        = "bind-vm"
  platform_id = "standard-v2"
  zone        = "ru-central1-d"

  resources {
    cores         = 2
    memory        = 2
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = var.vm_image_id
      size     = 20
      type     = "network-hdd"
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.subnet-d.id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.sg1.id]
  }

  metadata = {
    user-data = <<-EOT
      #cloud-config
      users:
        - name: s6ade
          sudo: ALL=(ALL) NOPASSWD:ALL
          shell: /bin/bash
          ssh_authorized_keys:
            - ${var.ssh_public_key}
    EOT
  }
}

# VM 2: Unbound (Зона A)
resource "yandex_compute_instance" "unbound_vm" {
  name        = "unbound-vm"
  platform_id = "standard-v2"
  zone        = "ru-central1-e"

  resources {
    cores         = 2
    memory        = 2
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = var.vm_image_id
      size     = 10
      type     = "network-hdd"
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.subnet-e.id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.sg1.id]
  }

  metadata = {
    user-data = <<-EOT
      #cloud-config
      users:
        - name: s6ade
          sudo: ALL=(ALL) NOPASSWD:ALL
          shell: /bin/bash
          ssh_authorized_keys:
            - ${var.ssh_public_key}
    EOT
  }
}

# VM 3: Client (Зона E)
resource "yandex_compute_instance" "client_vm" {
  name        = "client-vm"
  platform_id = "standard-v2"
  zone        = "ru-central1-e"

  resources {
    cores         = 2
    memory        = 2
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = var.vm_image_id
      size     = 10
      type     = "network-hdd"
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.subnet-e.id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.sg1.id]
  }

  metadata = {
    user-data = <<-EOT
      #cloud-config
      users:
        - name: s6ade
          sudo: ALL=(ALL) NOPASSWD:ALL
          shell: /bin/bash
          ssh_authorized_keys:
            - ${var.ssh_public_key}
    EOT
  }
}

# 5. Выводим IP-адреса (они понадобятся для Ansible)
output "bind_vm_ip" {
  value = yandex_compute_instance.bind_vm.network_interface.0.nat_ip_address
}
output "unbound_vm_ip" {
  value = yandex_compute_instance.unbound_vm.network_interface.0.nat_ip_address
}
output "client_vm_ip" {
  value = yandex_compute_instance.client_vm.network_interface.0.nat_ip_address
}