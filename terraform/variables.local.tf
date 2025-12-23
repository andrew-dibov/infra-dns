locals {
  hostnames = {
    bastion            = "bastion"
    stub_resolver      = "stub-resolver"
    recursive_resolver = "recursive-resolver"
    root               = "root"
    top_level_domain   = "top-level-domain"
    authoritative_a    = "authoritative-ns1"
    authoritative_b    = "authoritative-ns2"
    www_a              = "www-a"
    www_b              = "www-b"
  }
  hosts = {
    (local.hostnames.bastion) = {
      resources = {
        cores         = 2
        memory        = 2
        core_fraction = 20
      }

      initialize_params = {
        size = 10
      }

      network_interface = {
        nat                = true
        security_group_ids = [yandex_vpc_security_group.bastion.id]
      }

      scheduling_policy = {
        preemptible = true
      }

      ansible_role = "bastion"
    },
    (local.hostnames.stub_resolver) = {
      resources = {
        cores         = 2
        memory        = 2
        core_fraction = 20
      }

      initialize_params = {
        size = 10
      }

      network_interface = {
        nat                = false
        security_group_ids = [yandex_vpc_security_group.internal.id]
      }

      scheduling_policy = {
        preemptible = true
      }

      ansible_role = "stub-resolver"
    },
    (local.hostnames.recursive_resolver) = {
      resources = {
        cores         = 2
        memory        = 2
        core_fraction = 20
      }

      initialize_params = {
        size = 10
      }

      network_interface = {
        nat                = false
        security_group_ids = [yandex_vpc_security_group.internal.id]
      }

      scheduling_policy = {
        preemptible = true
      }

      ansible_role = "recursive-resolver"
    },
    (local.hostnames.root) = {
      resources = {
        cores         = 2
        memory        = 2
        core_fraction = 20
      }

      initialize_params = {
        size = 10
      }

      network_interface = {
        nat                = false
        security_group_ids = [yandex_vpc_security_group.internal.id]
      }

      scheduling_policy = {
        preemptible = true
      }

      ansible_role = "root"
    },
    (local.hostnames.top_level_domain) = {
      resources = {
        cores         = 2
        memory        = 2
        core_fraction = 20
      }

      initialize_params = {
        size = 10
      }

      network_interface = {
        nat                = false
        security_group_ids = [yandex_vpc_security_group.internal.id]
      }

      scheduling_policy = {
        preemptible = true
      }

      ansible_role = "top-level-domain"
    },
    (local.hostnames.authoritative_a) = {
      resources = {
        cores         = 2
        memory        = 2
        core_fraction = 20
      }

      initialize_params = {
        size = 10
      }

      network_interface = {
        nat                = false
        security_group_ids = [yandex_vpc_security_group.internal.id]
      }

      scheduling_policy = {
        preemptible = true
      }

      ansible_role = "authoritative-a"
    },
    (local.hostnames.authoritative_b) = {
      resources = {
        cores         = 2
        memory        = 2
        core_fraction = 20
      }

      initialize_params = {
        size = 10
      }

      network_interface = {
        nat                = false
        security_group_ids = [yandex_vpc_security_group.internal.id]
      }

      scheduling_policy = {
        preemptible = true
      }

      ansible_role = "authoritative-b"
    },
    (local.hostnames.www_a) = {
      resources = {
        cores         = 2
        memory        = 2
        core_fraction = 20
      }

      initialize_params = {
        size = 10
      }

      network_interface = {
        nat                = false
        security_group_ids = [yandex_vpc_security_group.internal.id]
      }

      scheduling_policy = {
        preemptible = true
      }

      ansible_role = "www-a"
    },
    (local.hostnames.www_b) = {
      resources = {
        cores         = 2
        memory        = 2
        core_fraction = 20
      }

      initialize_params = {
        size = 10
      }

      network_interface = {
        nat                = false
        security_group_ids = [yandex_vpc_security_group.internal.id]
      }

      scheduling_policy = {
        preemptible = true
      }

      ansible_role = "www-b"
    },
  }

  cloud_init_templates = {
    (local.hostnames.bastion)            = templatefile("${var.templates_dir}/cloud-init/bastion.yaml.tftpl", { packages = [] })
    (local.hostnames.stub_resolver)      = templatefile("${var.templates_dir}/cloud-init/default.yaml.tftpl", { packages = ["python3", "python3-pip", "iproute2"] })
    (local.hostnames.recursive_resolver) = templatefile("${var.templates_dir}/cloud-init/recursive-resolver.yaml.tftpl", { packages = ["python3", "python3-pip"] })
    (local.hostnames.root)               = templatefile("${var.templates_dir}/cloud-init/default.yaml.tftpl", { packages = ["python3", "python3-pip"] })
    (local.hostnames.top_level_domain)   = templatefile("${var.templates_dir}/cloud-init/default.yaml.tftpl", { packages = ["python3", "python3-pip"] })
    (local.hostnames.authoritative_a)    = templatefile("${var.templates_dir}/cloud-init/default.yaml.tftpl", { packages = ["python3", "python3-pip"] })
    (local.hostnames.authoritative_b)    = templatefile("${var.templates_dir}/cloud-init/default.yaml.tftpl", { packages = ["python3", "python3-pip"] })
    (local.hostnames.www_a)              = templatefile("${var.templates_dir}/cloud-init/default.yaml.tftpl", { packages = ["python3", "python3-pip"] })
    (local.hostnames.www_b)              = templatefile("${var.templates_dir}/cloud-init/default.yaml.tftpl", { packages = ["python3", "python3-pip"] })
  }
}
