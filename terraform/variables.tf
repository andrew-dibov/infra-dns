variable "tf_key__name" {
  type        = string
  default     = "auth.terraform.json"
  description = "file : service account key"
}

variable "tf_tpl__dir" {
  type        = string
  default     = "./templates"
  description = "dir : terraform templates"
}

# ---

variable "an__dir" {
  type        = string
  default     = "../ansible"
  description = "dir : ansible project"
}

variable "au__dir" {
  type        = string
  default     = "../.auth"
  description = "dir : ssh keys for remote hosts"
}

variable "py__ver" {
  type        = string
  default     = "3.12"
  description = "name : python version for remote hosts "
}

# ---

variable "vpc_net__name" {
  type        = string
  default     = "dns-net"
  description = "name : network name"
}

variable "vpc_gw__name" {
  type        = string
  default     = "dns-gw"
  description = "name : egress gateway for network"
}

variable "vpc_rt__name" {
  type        = string
  default     = "dns-rt"
  description = "name : routing table for egress traffic to gateway"
}

variable "vpc_sub__name" {
  type        = string
  default     = "dns-sub"
  description = "name : subnet name"
}

variable "vpc_sub__v4_cidr_blocks" {
  type        = list(string)
  default     = ["10.0.0.0/24"]
  description = "cidr : subnet classless inter-domain routing"
}

# ---

variable "vpc_sg_bast__name" {
  type        = string
  default     = "dns-sg-bastion"
  description = "name : bastion security group name"
}

variable "vpc_sg_elko__name" {
  type        = string
  default     = "dns-sg-elasticsearch"
  description = "name : elasticsearch security group name"
}

variable "vpc_sg_core__name" {
  type        = string
  default     = "dns-sg-core"
  description = "name : core infra security group name"
}

# ---

variable "img__name" {
  type        = string
  default     = "debian-12"
  description = "name : yandex cloud compute image"
}

variable "ins__platform_id" {
  type        = string
  default     = "standard-v3"
  description = "name : yandex cloud hardware platform"
}

