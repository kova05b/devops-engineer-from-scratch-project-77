data "yandex_vpc_network" "selected" {
  name = var.network_name
}

data "yandex_vpc_subnet" "selected" {
  name = var.subnet_name
}

data "yandex_compute_image" "ubuntu" {
  family = var.vm_image_family
}

resource "yandex_vpc_security_group" "web" {
  name       = "${var.project_name}-web-sg"
  network_id = data.yandex_vpc_network.selected.id

  ingress {
    protocol       = "TCP"
    description    = "HTTP from ALB and checks"
    port           = 80
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol       = "TCP"
    description    = "SSH access"
    port           = 22
    v4_cidr_blocks = var.ssh_cidr_blocks
  }

  egress {
    protocol       = "ANY"
    description    = "Allow all egress"
    from_port      = 0
    to_port        = 65535
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_compute_instance" "web" {
  for_each = toset(["web-1", "web-2"])

  name        = "${var.project_name}-${each.key}"
  platform_id = var.vm_platform_id

  resources {
    cores  = var.vm_cores
    memory = var.vm_memory
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      size     = var.vm_disk_size
      type     = "network-ssd"
    }
  }

  network_interface {
    subnet_id          = data.yandex_vpc_subnet.selected.id
    nat                = each.key == "web-1"
    security_group_ids = [yandex_vpc_security_group.web.id]
  }

  metadata = {
    ssh-keys = "${var.vm_user}:${var.ssh_public_key}"
    user-data = <<-EOT
      #cloud-config
      package_update: true
      packages:
        - nginx
      runcmd:
        - systemctl enable nginx
        - systemctl restart nginx
        - "echo '<h1>${var.project_name} ${each.key}</h1>' > /var/www/html/index.html"
    EOT
  }
}

resource "yandex_alb_target_group" "web" {
  name = "${var.project_name}-tg"

  dynamic "target" {
    for_each = yandex_compute_instance.web
    content {
      subnet_id  = data.yandex_vpc_subnet.selected.id
      ip_address = target.value.network_interface[0].ip_address
    }
  }
}

resource "yandex_alb_backend_group" "web" {
  name = "${var.project_name}-bg"

  http_backend {
    name             = "web-http-backend"
    weight           = 1
    port             = 80
    target_group_ids = [yandex_alb_target_group.web.id]

    healthcheck {
      timeout  = "2s"
      interval = "2s"
      healthy_threshold   = 2
      unhealthy_threshold = 2
      http_healthcheck {
        path = "/"
      }
    }
  }
}

resource "yandex_alb_http_router" "web" {
  name = "${var.project_name}-router"
}

resource "yandex_alb_virtual_host" "web" {
  name           = "${var.project_name}-vhost"
  http_router_id = yandex_alb_http_router.web.id
  authority      = [var.app_domain]

  route {
    name = "default-route"
    http_route {
      http_route_action {
        backend_group_id = yandex_alb_backend_group.web.id
        timeout          = "10s"
      }
    }
  }
}

resource "yandex_alb_load_balancer" "web" {
  name       = "${var.project_name}-alb"
  network_id = data.yandex_vpc_network.selected.id

  allocation_policy {
    location {
      zone_id   = var.yc_zone
      subnet_id = data.yandex_vpc_subnet.selected.id
    }
  }

  listener {
    name = "https-listener"
    endpoint {
      ports = [443]
      address {
        external_ipv4_address {}
      }
    }

    tls {
      default_handler {
        certificate_ids = [var.certificate_id]
        http_handler {
          http_router_id = yandex_alb_http_router.web.id
        }
      }
    }
  }
}
