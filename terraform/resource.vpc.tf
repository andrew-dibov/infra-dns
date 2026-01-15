resource "yandex_vpc_network" "net" {
  name        = var.vpc_net__name
  description = "VPC : network : net"
}

resource "yandex_vpc_gateway" "gw" {
  name        = var.vpc_gw__name
  description = "VPC : gateway : gw : egress for net"

  shared_egress_gateway {}
}

resource "yandex_vpc_route_table" "rt" {
  network_id = yandex_vpc_network.net.id

  name        = var.vpc_rt__name
  description = "VPC : routing table : rt : egress traffic to gw"

  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id         = yandex_vpc_gateway.gw.id
  }
}

resource "yandex_vpc_subnet" "sub" {
  network_id = yandex_vpc_network.net.id

  name        = var.vpc_sub__name
  description = "VPC : subnet : sub"

  zone           = var.yc__zone_id
  v4_cidr_blocks = var.vpc_sub__v4_cidr_blocks
  route_table_id = yandex_vpc_route_table.rt.id
}

# ---

resource "yandex_vpc_security_group" "bast" {
  network_id = yandex_vpc_network.net.id

  name        = var.vpc_sg_bast__name
  description = "VPC : security group : bastion : core access"

  ingress {
    protocol       = "TCP"
    port           = 22
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol       = "TCP"
    port           = 22
    v4_cidr_blocks = yandex_vpc_subnet.sub.v4_cidr_blocks
  }

  egress {
    protocol       = "UDP"
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

resource "yandex_vpc_security_group" "elko" {
  network_id = yandex_vpc_network.net.id

  name        = var.vpc_sg_elko__name
  description = "VPC : security group : elko : observability"

  ingress {
    protocol          = "TCP"
    port              = 22
    security_group_id = yandex_vpc_security_group.bast.id
  }

  ingress {
    protocol       = "TCP"
    port           = 5601
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol       = "ANY"
    v4_cidr_blocks = yandex_vpc_subnet.sub.v4_cidr_blocks
  }

  egress {
    protocol       = "UDP"
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

resource "yandex_vpc_security_group" "core" {
  network_id = yandex_vpc_network.net.id

  name        = var.vpc_sg_core__name
  description = "VPC : security group : core : core infra"

  ingress {
    protocol          = "TCP"
    port              = 22
    security_group_id = yandex_vpc_security_group.bast.id
  }

  ingress {
    protocol       = "UDP"
    port           = 53
    v4_cidr_blocks = yandex_vpc_subnet.sub.v4_cidr_blocks
  }

  ingress {
    protocol       = "TCP"
    port           = 53
    v4_cidr_blocks = yandex_vpc_subnet.sub.v4_cidr_blocks
  }

  egress {
    protocol       = "UDP"
    port           = 53
    v4_cidr_blocks = yandex_vpc_subnet.sub.v4_cidr_blocks
  }

  egress {
    protocol       = "TCP"
    port           = 53
    v4_cidr_blocks = yandex_vpc_subnet.sub.v4_cidr_blocks
  }

  egress {
    protocol       = "UDP"
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

  egress {
    protocol          = "ANY"
    security_group_id = yandex_vpc_security_group.elko.id
  }
}
