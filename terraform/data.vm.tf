variable "vm_family" {
  type    = string
  default = "debian-12"
}

# ---

data "yandex_compute_image" "debian" {
  family = var.vm_family
}
