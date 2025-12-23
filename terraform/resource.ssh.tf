resource "tls_private_key" "key" {
  for_each  = toset(values(local.hostnames))
  algorithm = "ED25519"
}

resource "local_file" "private_key" {
  for_each = tls_private_key.key

  filename        = "${var.auth_dir}/${each.key}"
  content         = each.value.private_key_openssh
  file_permission = "0600"
}

resource "local_file" "public_key" {
  for_each = tls_private_key.key

  filename        = "${var.auth_dir}/${each.key}.pub"
  content         = each.value.public_key_openssh
  file_permission = "0644"
}

resource "local_file" "ssh_config" {
  filename = "${var.auth_dir}/ssh_config"
  content = templatefile("${var.templates_dir}/auth/ssh-config.tftpl", {
    bastion = local.hostnames.bastion
    hosts = {
      for name, vm in yandex_compute_instance.hosts :
      name => {
        is_bastion = name == (local.hostnames.bastion)
        host_name  = name == (local.hostnames.bastion) ? vm.network_interface[0].nat_ip_address : vm.network_interface[0].ip_address
        key_path   = "${var.auth_dir}/${name}"
        user       = "debian"
      }
    }
  })
  file_permission = "0600"
}
