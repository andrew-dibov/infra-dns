locals {
  inss__names = {
    elko = "dns-ins-elk"
    bast = "dns-ins-bastion"
    root = "dns-ins-root"
    tldd = "dns-ins-top-level-domain"
    au_a = "dns-ins-authoritative-a"
    au_b = "dns-ins-authoritative-b"
    recr = "dns-ins-recursor"
    stub = "dns-ins-stub"
  }
  inss__cfgs = {
    (local.inss__names.elko) = {
      description = "observability instance : elko : elasticsearch + logstash + kibana"

      resources = {
        cores         = 4
        memory        = 4
        core_fraction = 20
      }

      initialize_params = {
        size = 20
      }

      network_interface = {
        nat                = true
        security_group_ids = [yandex_vpc_security_group.elko.id]
      }

      scheduling_policy = {
        preemptible = true
      }

      role = "elko"
    },
    (local.inss__names.bast) = {
      description = "bastion instance : bast : ssh gateway"

      resources = {
        cores         = 2
        memory        = 2
        core_fraction = 20
      }

      initialize_params = {
        size = 5
      }

      network_interface = {
        nat                = true
        security_group_ids = [yandex_vpc_security_group.bast.id]
      }

      scheduling_policy = {
        preemptible = true
      }

      role = "bast"
    },
    (local.inss__names.root) = {
      description = "DNS instance : root : root domain name server"

      resources = {
        cores         = 2
        memory        = 2
        core_fraction = 20
      }

      initialize_params = {
        size = 5
      }

      network_interface = {
        nat                = false
        security_group_ids = [yandex_vpc_security_group.core.id]
      }

      scheduling_policy = {
        preemptible = true
      }

      role = "root"
    },
    (local.inss__names.tldd) = {
      description = "DNS instance : tldd : top level domain name server"

      resources = {
        cores         = 2
        memory        = 2
        core_fraction = 20
      }

      initialize_params = {
        size = 5
      }

      network_interface = {
        nat                = false
        security_group_ids = [yandex_vpc_security_group.core.id]
      }

      scheduling_policy = {
        preemptible = true
      }

      role = "tldd"
    },
    (local.inss__names.au_a) = {
      description = "DNS instance : au_a : primary authority domain name server"

      resources = {
        cores         = 2
        memory        = 2
        core_fraction = 20
      }

      initialize_params = {
        size = 5
      }

      network_interface = {
        nat                = false
        security_group_ids = [yandex_vpc_security_group.core.id]
      }

      scheduling_policy = {
        preemptible = true
      }

      role = "au_a"
    },
    (local.inss__names.au_b) = {
      description = "DNS instance : au_b : secondary authority domain name server"

      resources = {
        cores         = 2
        memory        = 2
        core_fraction = 20
      }

      initialize_params = {
        size = 5
      }

      network_interface = {
        nat                = false
        security_group_ids = [yandex_vpc_security_group.core.id]
      }

      scheduling_policy = {
        preemptible = true
      }

      role = "au_b"
    },
    (local.inss__names.recr) = {
      description = "resolver instance : recr : recursive resolver"

      resources = {
        cores         = 2
        memory        = 2
        core_fraction = 20
      }

      initialize_params = {
        size = 5
      }

      network_interface = {
        nat                = false
        security_group_ids = [yandex_vpc_security_group.core.id]
      }

      scheduling_policy = {
        preemptible = true
      }

      role = "recr"
    },
    (local.inss__names.stub) = {
      description = "resolver instance : stub : stub resolver"

      resources = {
        cores         = 2
        memory        = 2
        core_fraction = 20
      }

      initialize_params = {
        size = 5
      }

      network_interface = {
        nat                = false
        security_group_ids = [yandex_vpc_security_group.core.id]
      }

      scheduling_policy = {
        preemptible = true
      }

      role = "stub"
    },
  }
  inss__tpls = {
    (local.inss__names.elko) = templatefile("${var.tf_tpl__dir}/ci.dock.tftpl", { pkgs = ["python${var.py__ver}", "ca-certificates", "curl", "dnsutils"] })
    (local.inss__names.bast) = templatefile("${var.tf_tpl__dir}/ci.bast.tftpl", { pkgs = [] })
    (local.inss__names.root) = templatefile("${var.tf_tpl__dir}/ci.deft.tftpl", { pkgs = ["python${var.py__ver}", "dnsutils"] })
    (local.inss__names.tldd) = templatefile("${var.tf_tpl__dir}/ci.deft.tftpl", { pkgs = ["python${var.py__ver}", "dnsutils"] })
    (local.inss__names.au_a) = templatefile("${var.tf_tpl__dir}/ci.deft.tftpl", { pkgs = ["python${var.py__ver}", "dnsutils"] })
    (local.inss__names.au_b) = templatefile("${var.tf_tpl__dir}/ci.deft.tftpl", { pkgs = ["python${var.py__ver}", "dnsutils"] })
    (local.inss__names.recr) = templatefile("${var.tf_tpl__dir}/ci.deft.tftpl", { pkgs = ["python${var.py__ver}", "dnsutils"] })
    (local.inss__names.stub) = templatefile("${var.tf_tpl__dir}/ci.dock.tftpl", { pkgs = ["python${var.py__ver}", "ca-certificates", "curl", "dnsutils"] })
  }
}
