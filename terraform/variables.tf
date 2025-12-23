variable "vpc_network_name" {
  type    = string
  default = "dns-net"
}

variable "vpc_gateway_nat_name" {
  type    = string
  default = "dns-nat-gw"
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

variable "security_group_bastion_name" {
  type    = string
  default = "dns-bastion-sg"
}

variable "security_group_internal_name" {
  type    = string
  default = "dns-internal-sg"
}

# ---

variable "platform_id" {
  type    = string
  default = "standard-v3"
}
