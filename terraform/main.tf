# terraform.tfvars
variable "yandex_cloud_cloud_id" {
  type = string
}

# terraform.tfvars
variable "yandex_cloud_folder_id" {
  type = string
}

# terraform.tfvars
variable "yandex_cloud_zone_id" {
  type = string
}

# terraform.tfvars
variable "auth_dir" {
  type = string
}

# terraform.tfvars
variable "templates_dir" {
  type = string
}

# terraform.tfvars
variable "service_account_key_name" {
  type = string
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
  cloud_id  = var.yandex_cloud_cloud_id
  folder_id = var.yandex_cloud_folder_id

  zone                     = var.yandex_cloud_zone_id
  service_account_key_file = "${var.auth_dir}/${var.service_account_key_name}"
}
