resource "yandex_vpc_network" "net" {
  name = var.vpc_network_name
}

resource "yandex_vpc_gateway" "nat" {
  name = var.vpc_gateway_nat_name
  shared_egress_gateway {}
}

resource "yandex_vpc_route_table" "nat" {
  network_id = yandex_vpc_network.net.id
  name       = var.vpc_route_table_nat_name

  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id         = yandex_vpc_gateway.nat.id
  }
}

resource "yandex_vpc_subnet" "subnet" {
  network_id = yandex_vpc_network.net.id

  name           = var.vpc_subnet_name
  zone           = var.yandex_cloud_zone_id
  v4_cidr_blocks = var.vpc_subnet_v4_cidr_blocks
  route_table_id = yandex_vpc_route_table.nat.id
}

resource "yandex_vpc_security_group" "bastion" {
  network_id = yandex_vpc_network.net.id
  name       = var.security_group_bastion_name

  ingress {
    protocol       = "TCP"
    port           = 22
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol       = "TCP"
    port           = 22
    v4_cidr_blocks = yandex_vpc_subnet.subnet.v4_cidr_blocks
  }
}

resource "yandex_vpc_security_group" "internal" {
  network_id = yandex_vpc_network.net.id
  name       = var.security_group_internal_name

  ingress {
    protocol          = "TCP"
    port              = 22
    security_group_id = yandex_vpc_security_group.bastion.id
  }

  ingress {
    protocol       = "UDP"
    port           = 53
    v4_cidr_blocks = yandex_vpc_subnet.subnet.v4_cidr_blocks
  }

  ingress {
    protocol       = "TCP"
    port           = 53
    v4_cidr_blocks = yandex_vpc_subnet.subnet.v4_cidr_blocks
  }

  ingress {
    protocol       = "ANY"
    v4_cidr_blocks = yandex_vpc_subnet.subnet.v4_cidr_blocks
  }

  egress {
    protocol       = "UDP"
    port           = 53
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol       = "TCP"
    port           = 53
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol       = "TCP"
    port           = 80
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol       = "TCP"
    port           = 443
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}
