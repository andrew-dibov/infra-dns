# terraform.tfvars
variable "yc_cloud_id" {
  type = string
}

# terraform.tfvars
variable "yc_folder_id" {
  type = string
}

# terraform.tfvars
variable "yc_zone_id" {
  type = string
}

# terraform.tfvars
variable "auth_dir" {
  type = string
}

# terraform.tfvars
variable "tpls_dir" {
  type = string
}

# terraform.tfvars
variable "sa_key_name" {
  type = string
}

# ---

locals {
  compute_instance_names = {
    bastion_name          = "dns-bastion"
    client_name           = "dns-stub-resolver"      # Stub Resolver : клиент, передающий запрос дальше
    resolver_name         = "dns-recursive-resolver" # Recursive Resolver : сервер, обращающийся по цепочке
    root_name             = "dns-root-server"
    top_level_domain_name = "dns-top-level-domain-server"
    authority_a_name      = "dns-authoritative-ns1"
    authority_b_name      = "dns-authoritative-ns2"
    load_balancer_name    = "dns-load-balancer"
  }
}

# ---

terraform {
  required_version = "~> 1.14.0" # 1.14.X

  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "~> 0.174.0" # 0.174.X
    }

    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.1.0" # 4.1.X
    }

    local = {
      source  = "hashicorp/local"
      version = "~> 2.6.1" # 2.6.X
    }
  }
}

provider "yandex" {
  cloud_id  = var.yc_cloud_id
  folder_id = var.yc_folder_id

  zone                     = var.yc_zone_id
  service_account_key_file = "${var.auth_dir}/${var.sa_key_name}"
}
