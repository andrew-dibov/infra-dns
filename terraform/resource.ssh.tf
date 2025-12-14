resource "tls_private_key" "key" {
  for_each  = toset(values(local.compute_instance_names))
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

# ---

resource "local_file" "ssh_config" {
  filename = "${var.auth_dir}/ssh_config"
  content = templatefile("${var.tpls_dir}/ssh-config.tftpl", {
    hosts = {
      for name, vm in yandex_compute_instance.compute_instance :
      name => {
        is_bastion = name == (local.compute_instance_names.bastion_name)
        host_name  = name == (local.compute_instance_names.bastion_name) ? vm.network_interface[0].nat_ip_address : vm.network_interface[0].ip_address
        key_path   = "${var.auth_dir}/${name}"
        user       = "debian"
      }
    }
  })
  file_permission = "0600"
}
