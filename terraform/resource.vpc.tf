variable "vpc_network_name" {
  type    = string
  default = "dns-net"
}

variable "vpc_gateway_nat_name" {
  type    = string
  default = "dns-nat-gateway"
}

variable "vpc_route_table_nat_name" {
  type    = string
  default = "dns-nat-route-table"
}

variable "vpc_subnet_name" {
  type    = string
  default = "dns-subnet"
}

variable "vpc_subnet_v4_cidr_blocks" {
  type    = list(string)
  default = ["10.0.0.0/24"]
}

# ---

resource "yandex_vpc_network" "network" {
  name = var.vpc_network_name
}

resource "yandex_vpc_gateway" "nat" {
  name = var.vpc_gateway_nat_name
  shared_egress_gateway {}
}

resource "yandex_vpc_route_table" "nat" {
  network_id = yandex_vpc_network.network.id
  name       = var.vpc_route_table_nat_name

  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id         = yandex_vpc_gateway.nat.id
  }
}

resource "yandex_vpc_subnet" "subnet" {
  network_id = yandex_vpc_network.network.id

  name           = var.vpc_subnet_name
  zone           = var.yc_zone_id
  v4_cidr_blocks = var.vpc_subnet_v4_cidr_blocks
  route_table_id = yandex_vpc_route_table.nat.id
}

# ---

variable "security_group_bastion_name" {
  type    = string
  default = "dns-bastion-sg"
}

variable "security_group_internal_name" {
  type    = string
  default = "dns-internal-sg"
}

# ---

resource "yandex_vpc_security_group" "bastion" {
  network_id = yandex_vpc_network.network.id
  name       = var.security_group_bastion_name

  ingress { # Входящий SSH : все адреса
    protocol       = "TCP"
    port           = 22
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  egress { # Исходящий SSH : все адреса внутренней подсети
    protocol       = "TCP"
    port           = 22
    v4_cidr_blocks = yandex_vpc_subnet.subnet.v4_cidr_blocks
  }
}

resource "yandex_vpc_security_group" "internal" {
  network_id = yandex_vpc_network.network.id
  name       = var.security_group_internal_name

  ingress { # Входищяй SSH : только от bastion
    protocol          = "TCP"
    port              = 22
    security_group_id = yandex_vpc_security_group.bastion.id
  }

  ingress { # Входящий DNS : все адреса внутренней подсети
    protocol       = "UDP"
    port           = 53
    v4_cidr_blocks = yandex_vpc_subnet.subnet.v4_cidr_blocks
  }

  ingress { # Входящий DNS : все адреса внутренней подсети
    protocol       = "TCP"
    port           = 53
    v4_cidr_blocks = yandex_vpc_subnet.subnet.v4_cidr_blocks
  }

  ingress { # Входящий трафик : все адреса внутренней подсети
    protocol       = "ANY"
    v4_cidr_blocks = yandex_vpc_subnet.subnet.v4_cidr_blocks
  }

  egress { # Исходящий DNS : все адреса
    protocol       = "UDP"
    port           = 53
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  egress { # Исходящий DNS : все адреса
    protocol       = "TCP"
    port           = 53
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  egress { # Исходящий HTTP : все адреса
    protocol       = "TCP"
    port           = 80
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  egress { # Исходящий HTTPS : все адреса
    protocol       = "TCP"
    port           = 443
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}
