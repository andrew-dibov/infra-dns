variable "yc__cloud_id" {
  type        = string
  description = "terraform.tfvars"
}

variable "yc__folder_id" {
  type        = string
  description = "terraform.tfvars"
}

variable "yc__zone_id" {
  type        = string
  description = "terraform.tfvars"
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
  cloud_id                 = var.yc__cloud_id
  folder_id                = var.yc__folder_id
  zone                     = var.yc__zone_id
  service_account_key_file = var.tf_key__name
}
