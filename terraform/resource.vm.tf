variable "compute_instance_platform_id" {
  type    = string
  default = "standard-v3"
}

locals {
  compute_instance_configs = {
    (local.compute_instance_names.bastion_name) = {
      compute_instance_resources = {
        cores         = 2
        memory        = 2
        core_fraction = 20
      }

      compute_instance_initialize_params = {
        size = 10
      }

      compute_instance_network_interface = {
        nat                = true
        security_group_ids = [yandex_vpc_security_group.bastion.id]
      }

      compute_instance_scheduling_policy = {
        preemptible = true
      }
    },
    (local.compute_instance_names.client_name) = {
      compute_instance_resources = {
        cores         = 2
        memory        = 2
        core_fraction = 20
      }

      compute_instance_initialize_params = {
        size = 10
      }

      compute_instance_network_interface = {
        nat                = false
        security_group_ids = [yandex_vpc_security_group.internal.id]
      }

      compute_instance_scheduling_policy = {
        preemptible = true
      }
    },
    (local.compute_instance_names.resolver_name) = {
      compute_instance_resources = {
        cores         = 2
        memory        = 2
        core_fraction = 20
      }

      compute_instance_initialize_params = {
        size = 10
      }

      compute_instance_network_interface = {
        nat                = false
        security_group_ids = [yandex_vpc_security_group.internal.id]
      }

      compute_instance_scheduling_policy = {
        preemptible = true
      }
    },
    (local.compute_instance_names.root_name) = {
      compute_instance_resources = {
        cores         = 2
        memory        = 2
        core_fraction = 20
      }

      compute_instance_initialize_params = {
        size = 10
      }

      compute_instance_network_interface = {
        nat                = false
        security_group_ids = [yandex_vpc_security_group.internal.id]
      }

      compute_instance_scheduling_policy = {
        preemptible = true
      }
    },
    (local.compute_instance_names.top_level_domain_name) = {
      compute_instance_resources = {
        cores         = 2
        memory        = 2
        core_fraction = 20
      }

      compute_instance_initialize_params = {
        size = 10
      }

      compute_instance_network_interface = {
        nat                = false
        security_group_ids = [yandex_vpc_security_group.internal.id]
      }

      compute_instance_scheduling_policy = {
        preemptible = true
      }
    },
    (local.compute_instance_names.authority_a_name) = {
      compute_instance_resources = {
        cores         = 2
        memory        = 2
        core_fraction = 20
      }

      compute_instance_initialize_params = {
        size = 10
      }

      compute_instance_network_interface = {
        nat                = false
        security_group_ids = [yandex_vpc_security_group.internal.id]
      }

      compute_instance_scheduling_policy = {
        preemptible = true
      }
    },
    (local.compute_instance_names.authority_b_name) = {
      compute_instance_resources = {
        cores         = 2
        memory        = 2
        core_fraction = 20
      }

      compute_instance_initialize_params = {
        size = 10
      }

      compute_instance_network_interface = {
        nat                = false
        security_group_ids = [yandex_vpc_security_group.internal.id]
      }

      compute_instance_scheduling_policy = {
        preemptible = true
      }
    },
    (local.compute_instance_names.load_balancer_name) = {
      compute_instance_resources = {
        cores         = 2
        memory        = 2
        core_fraction = 20
      }

      compute_instance_initialize_params = {
        size = 10
      }

      compute_instance_network_interface = {
        nat                = false
        security_group_ids = [yandex_vpc_security_group.internal.id]
      }

      compute_instance_scheduling_policy = {
        preemptible = true
      }
    },
  }

  compute_instance_cloud_init_templates = {
    (local.compute_instance_names.bastion_name)          = templatefile("${var.tpls_dir}/cloud-init-bastion.yaml.tftpl", { packages = [] })
    (local.compute_instance_names.client_name)           = templatefile("${var.tpls_dir}/cloud-init.yaml.tftpl", { packages = ["python3", "python3-pip", "iproute2"] })
    (local.compute_instance_names.resolver_name)         = templatefile("${var.tpls_dir}/cloud-init.yaml.tftpl", { packages = ["python3", "python3-pip"] })
    (local.compute_instance_names.root_name)             = templatefile("${var.tpls_dir}/cloud-init.yaml.tftpl", { packages = ["python3", "python3-pip"] })
    (local.compute_instance_names.top_level_domain_name) = templatefile("${var.tpls_dir}/cloud-init.yaml.tftpl", { packages = ["python3", "python3-pip"] })
    (local.compute_instance_names.authority_a_name)      = templatefile("${var.tpls_dir}/cloud-init.yaml.tftpl", { packages = ["python3", "python3-pip"] })
    (local.compute_instance_names.authority_b_name)      = templatefile("${var.tpls_dir}/cloud-init.yaml.tftpl", { packages = ["python3", "python3-pip"] })
    (local.compute_instance_names.load_balancer_name)    = templatefile("${var.tpls_dir}/cloud-init.yaml.tftpl", { packages = ["python3", "python3-pip"] })
  }
}

# ---

resource "yandex_compute_instance" "compute_instance" {
  for_each = local.compute_instance_configs

  zone        = yandex_vpc_subnet.subnet.zone
  platform_id = var.compute_instance_platform_id

  name     = each.key
  hostname = each.key

  resources {
    cores         = each.value.compute_instance_resources.cores
    memory        = each.value.compute_instance_resources.memory
    core_fraction = each.value.compute_instance_resources.core_fraction
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.debian.id
      size     = each.value.compute_instance_initialize_params.size
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.subnet.id
    nat                = each.value.compute_instance_network_interface.nat
    security_group_ids = each.value.compute_instance_network_interface.security_group_ids
  }

  scheduling_policy {
    preemptible = each.value.compute_instance_scheduling_policy.preemptible
  }

  metadata = {
    ssh-keys  = "debian:${tls_private_key.key[each.key].public_key_openssh}"
    user-data = local.compute_instance_cloud_init_templates[each.key]
  }
}
