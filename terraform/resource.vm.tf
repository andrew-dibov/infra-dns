resource "yandex_compute_instance" "hosts" {
  for_each = local.hosts

  zone        = yandex_vpc_subnet.subnet.zone
  platform_id = var.platform_id

  name     = each.key
  hostname = each.key

  labels = {
    ansible_role = each.value.ansible_role
  }

  resources {
    cores         = each.value.resources.cores
    memory        = each.value.resources.memory
    core_fraction = each.value.resources.core_fraction
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.debian.id
      size     = each.value.initialize_params.size
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.subnet.id
    nat                = each.value.network_interface.nat
    security_group_ids = each.value.network_interface.security_group_ids
  }

  scheduling_policy {
    preemptible = each.value.scheduling_policy.preemptible
  }

  metadata = {
    ssh-keys  = "debian:${tls_private_key.key[each.key].public_key_openssh}"
    user-data = local.cloud_init_templates[each.key]
  }
}

resource "local_file" "ansible_cfg" {
  filename = "../ansible/ansible.cfg"
  content = templatefile("${var.templates_dir}/ansible/ansible.cfg.tftpl", {
    auth_dir = var.auth_dir
  })
}

resource "local_file" "ansible_inventory" {
  filename = "../ansible/inventory/hosts.yaml"
  content = templatefile("${var.templates_dir}/ansible/inventory.yaml.tftpl", {
    hosts = yandex_compute_instance.hosts
  })
}

resource "local_file" "ansible_variables" {
  filename = "../ansible/variables/variables.yaml"
  content = templatefile("${var.templates_dir}/ansible/variables.yaml.tftpl", {
    stub_resolver_ip      = yandex_compute_instance.hosts["${local.hostnames.stub_resolver}"].network_interface[0].ip_address
    recursive_resolver_ip = yandex_compute_instance.hosts["${local.hostnames.recursive_resolver}"].network_interface[0].ip_address
    root_ip               = yandex_compute_instance.hosts["${local.hostnames.root}"].network_interface[0].ip_address
    top_level_domain_ip   = yandex_compute_instance.hosts["${local.hostnames.top_level_domain}"].network_interface[0].ip_address
    authoritative_a_ip    = yandex_compute_instance.hosts["${local.hostnames.authoritative_a}"].network_interface[0].ip_address
    authoritative_b_ip    = yandex_compute_instance.hosts["${local.hostnames.authoritative_b}"].network_interface[0].ip_address
    www_a_ip              = yandex_compute_instance.hosts["${local.hostnames.www_a}"].network_interface[0].ip_address
    www_b_ip              = yandex_compute_instance.hosts["${local.hostnames.www_b}"].network_interface[0].ip_address
  })
}
