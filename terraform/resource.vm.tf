data "yandex_compute_image" "img" {
  family = var.img__name
}

resource "yandex_compute_instance" "inss" {
  for_each = local.inss__cfgs

  zone        = yandex_vpc_subnet.sub.zone
  platform_id = var.ins__platform_id

  name        = each.key
  description = each.value.description
  hostname    = each.key

  labels = {
    role = each.value.role
  }

  resources {
    cores         = each.value.resources.cores
    memory        = each.value.resources.memory
    core_fraction = each.value.resources.core_fraction
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.img.id
      size     = each.value.initialize_params.size
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.sub.id
    nat                = each.value.network_interface.nat
    security_group_ids = each.value.network_interface.security_group_ids
  }

  scheduling_policy {
    preemptible = each.value.scheduling_policy.preemptible
  }

  metadata = {
    ssh-keys  = "debian:${tls_private_key.key[each.key].public_key_openssh}"
    user-data = local.inss__tpls[each.key]
  }
}

# ---

resource "local_file" "ansi_cfg" {
  filename = "${var.an__dir}/ansible.cfg"
  content = templatefile("${var.tf_tpl__dir}/ansi.cfg.tftpl", {
    py = "python${var.py__ver}"
  })
}

resource "local_file" "ansi_inv" {
  filename = "${var.an__dir}/inventory/terraform.yaml"
  content = templatefile("${var.tf_tpl__dir}/ansi.inv.tftpl", {
    inss = yandex_compute_instance.inss
  })
}

resource "local_file" "ansi_var" {
  filename = "${var.an__dir}/variables/terraform.yaml"
  content = templatefile("${var.tf_tpl__dir}/ansi.var.tftpl", {
    su_cidr = var.vpc_sub__v4_cidr_blocks[0]
    elko_ip = yandex_compute_instance.inss["${local.inss__names.elko}"].network_interface[0].ip_address
    root_ip = yandex_compute_instance.inss["${local.inss__names.root}"].network_interface[0].ip_address
    tldd_ip = yandex_compute_instance.inss["${local.inss__names.tldd}"].network_interface[0].ip_address
    au_a_ip = yandex_compute_instance.inss["${local.inss__names.au_a}"].network_interface[0].ip_address
    au_b_ip = yandex_compute_instance.inss["${local.inss__names.au_b}"].network_interface[0].ip_address
    recr_ip = yandex_compute_instance.inss["${local.inss__names.recr}"].network_interface[0].ip_address
    stub_ip = yandex_compute_instance.inss["${local.inss__names.stub}"].network_interface[0].ip_address
  })
}
