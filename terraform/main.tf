terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
}

provider "yandex" {
  token     = "${var.yc_token}"
  cloud_id  = "${var.yc_cloudid}"
  folder_id = "${var.yc_folderid}"
  zone      = "${var.yc_zone}"
}

# VM BASTION

resource "yandex_compute_instance" "bastion" {
  name = "vm-bastion"
  zone = "${var.yc_zone}"
  allow_stopping_for_update = "${var.yc_stoppable}"
  resources {
    cores  = 2
    memory = 1
    core_fraction = 20
  }
  scheduling_policy {
    preemptible = "${var.yc_preemptible}"
  }
  boot_disk {
    initialize_params {
      image_id = "${var.yc_imageid}"
      size = 10
    }
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-bastion.id
    security_group_ids = [yandex_vpc_security_group.bastionsg.id]
    nat       = true
    nat_ip_address     = "158.160.34.197"
  }
  metadata = {
    user-data = "${file("./meta.txt")}"
  }
  provisioner "file" {
    source      = "files/id_rsa"
    destination = "/home/deploy/.ssh/id_rsa"
    connection {
    type    = "ssh"
    user    = "deploy"
    host    = "${var.yc_bastion-ip}"
    private_key = file(pathexpand("~/.ssh/id_rsa")) 
    }
  }
  provisioner "remote-exec" {
    inline = [ "chmod 0400 /home/deploy/.ssh/id_rsa" ]
    connection {
    type    = "ssh"
    user    = "deploy"
    host    = "${var.yc_bastion-ip}"
    private_key = file(pathexpand("~/.ssh/id_rsa")) 
    }
  }
}

# VM NGINX 1

resource "yandex_compute_instance" "nginx-one" {
  name = "vm-nginx-1"
  zone = "ru-central1-a"
  allow_stopping_for_update = "${var.yc_stoppable}"
  resources {
    cores  = 2
    memory = 1
    core_fraction = 20
  }
  boot_disk {
    initialize_params {
      image_id = "${var.yc_imageid}"
      size = 10
    }
  }
  scheduling_policy {
    preemptible = "${var.yc_preemptible}"
  }
  network_interface {
    subnet_id          = yandex_vpc_subnet.subnet-nginx-one.id
    security_group_ids = [yandex_vpc_security_group.nginxsg.id]
  }
  metadata = {
    user-data = "${file("./meta.txt")}"
  }
}

# VM NGINX 2

resource "yandex_compute_instance" "nginx-two" {
  name = "vm-nginx-2"
  zone = "ru-central1-b"
  allow_stopping_for_update = "${var.yc_stoppable}"
  resources {
    cores  = 2
    memory = 1
    core_fraction = 20
  }
  boot_disk {
    initialize_params {
      image_id = "${var.yc_imageid}"
      size = 10
    }
  }
  scheduling_policy {
    preemptible = "${var.yc_preemptible}"
  }
  network_interface {
    subnet_id          = yandex_vpc_subnet.subnet-nginx-two.id
    security_group_ids = [yandex_vpc_security_group.nginxsg.id]
  }
  metadata = {
    user-data = "${file("./meta.txt")}"
  }
}

# VM ELASTICSEARCH/LOGSTASH

resource "yandex_compute_instance" "elasticsearch" {
  name = "vm-elasticsearch"
  zone = "${var.yc_zone}"
  allow_stopping_for_update = "${var.yc_stoppable}"
  resources {
    cores  = 2
    memory = 6
    core_fraction = 20
  }
  boot_disk {
    initialize_params {
      image_id = "${var.yc_imageid}"
      size = 20
    }
  }
  scheduling_policy {
    preemptible = "${var.yc_preemptible}"
  }
  network_interface {
    subnet_id          = yandex_vpc_subnet.subnet-elastcisearch.id
    security_group_ids = [yandex_vpc_security_group.elasticsg.id]
  }
  metadata = {
    user-data = "${file("./meta.txt")}"
  }
}

# VM KIBANA

resource "yandex_compute_instance" "kibana" {
  name = "vm-kibana"
  zone = "${var.yc_zone}"
  allow_stopping_for_update = "${var.yc_stoppable}"
  resources {
    cores  = 2
    memory = 1
    core_fraction = 20
  }
  boot_disk {
    initialize_params {
      image_id = "${var.yc_imageid}"
      size = 10
    }
  }
  scheduling_policy {
    preemptible = "${var.yc_preemptible}"
  }
  network_interface {
    subnet_id          = yandex_vpc_subnet.subnet-public.id
    security_group_ids = [yandex_vpc_security_group.publicsg.id]
  }
  metadata = {
    user-data = "${file("./meta.txt")}"
  }
}

# VM PROMETHEUS

resource "yandex_compute_instance" "prometheus" {
  name = "vm-prometheus"
  zone = "${var.yc_zone}"
  allow_stopping_for_update = "${var.yc_stoppable}"
  resources {
    cores  = 2
    memory = 1
    core_fraction = 20
  }
  boot_disk {
    initialize_params {
      image_id = "${var.yc_imageid}"
      size = 20
    }
  }
  scheduling_policy {
    preemptible = "${var.yc_preemptible}"
  }
  network_interface {
    subnet_id          = yandex_vpc_subnet.subnet-prometheus.id
    security_group_ids = [yandex_vpc_security_group.prometheussg.id]
  }
  metadata = {
    user-data = "${file("./meta.txt")}"
  }
}

# VM GRAFANA

resource "yandex_compute_instance" "grafana" {
  name = "vm-grafana"
  zone = "${var.yc_zone}"
  allow_stopping_for_update = "${var.yc_stoppable}"
  resources {
    cores  = 2
    memory = 1
    core_fraction = 20
  }
  boot_disk {
    initialize_params {
      image_id = "${var.yc_imageid}"
      size = 20
    }
  }
  scheduling_policy {
    preemptible = "${var.yc_preemptible}"
  }
  network_interface {
    subnet_id          = yandex_vpc_subnet.subnet-public.id
    security_group_ids = [yandex_vpc_security_group.publicsg.id]
  }
  metadata = {
    user-data = "${file("./meta.txt")}"
  }
}

# СЕТИ И ПОДСЕТИ---------------------------------------------------------

resource "yandex_vpc_network" "network-netology" {
  name = "all-net"
}

resource "yandex_vpc_subnet" "subnet-bastion" {
  name           = "sbn-bastion"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network-netology.id
  v4_cidr_blocks = ["192.168.9.0/24"]
}

resource "yandex_vpc_subnet" "subnet-public" {
  name           = "sbn-public"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network-netology.id
  route_table_id = yandex_vpc_route_table.rt-main.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}

resource "yandex_vpc_subnet" "subnet-nginx-one" {
  name           = "sbn-nginx-1"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network-netology.id
  route_table_id = yandex_vpc_route_table.rt-main.id
  v4_cidr_blocks = ["192.168.11.0/24"]
}

resource "yandex_vpc_subnet" "subnet-nginx-two" {
  name           = "sbn-nginx-2"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.network-netology.id
  route_table_id = yandex_vpc_route_table.rt-main.id
  v4_cidr_blocks = ["192.168.12.0/24"]
}

resource "yandex_vpc_subnet" "subnet-elastcisearch" {
  name           = "sbn-elasticsearch"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network-netology.id
  route_table_id = yandex_vpc_route_table.rt-main.id
  v4_cidr_blocks = ["192.168.13.0/24"]
}

resource "yandex_vpc_subnet" "subnet-prometheus" {
  name           = "sbn-prometheus"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network-netology.id
  route_table_id = yandex_vpc_route_table.rt-main.id
  v4_cidr_blocks = ["192.168.14.0/24"]
}

# SECURITY GROUPS ------------------------------------------------------

resource "yandex_vpc_security_group" "bastionsg" {
  name        = "bastion-sg"
  description = "SG for bastion"
  network_id  = "${yandex_vpc_network.network-netology.id}"
  ingress {
    protocol       = "TCP"
    description    = "All in"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    protocol       = "TCP"
    description    = "All out"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group" "publicsg" {
  name        = "public-sg"
  description = "SG for bastion"
  network_id  = "${yandex_vpc_network.network-netology.id}"
  ingress {
    protocol       = "TCP"
    description    = "SSH from bastion"
    v4_cidr_blocks = ["192.168.9.0/24"]
    port           = 22
  }
  ingress {
    protocol       = "TCP"
    description    = "in kibana"
    v4_cidr_blocks = ["192.168.9.0/24"]
    port           = 5601
  }
  ingress {
    protocol       = "TCP"
    description    = "in grafana"
    v4_cidr_blocks = ["192.168.9.0/24"]
    port           = 3000
  }
  egress {
    protocol       = "TCP"
    description    = "All out"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group" "nginxsg" {
  name        = "nginx-sg"
  description = "SG for nginx"
  network_id  = "${yandex_vpc_network.network-netology.id}"
  ingress {
    protocol       = "TCP"
    description    = "SSH from bastion"
    v4_cidr_blocks = ["192.168.9.0/24"]
    port           = 22
  }
  ingress {
    protocol       = "TCP"
    description    = "All HTTP in"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 80
  }
  ingress {
    protocol       = "TCP"
    description    = "node exporter in"
    v4_cidr_blocks = ["192.168.14.0/24"]
    port           = 9100
  }
  ingress {
    protocol       = "TCP"
    description    = "nginx log exporter in"
    v4_cidr_blocks = ["192.168.14.0/24"]
    port           = 4040
  }
  egress {
    protocol       = "TCP"
    description    = "All out"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group" "elasticsg" {
  name        = "elastic-sg"
  description = "SG for elastic and logstash"
  network_id  = "${yandex_vpc_network.network-netology.id}"
  ingress {
    protocol       = "TCP"
    description    = "SSH from bastion"
    v4_cidr_blocks = ["192.168.9.0/24"]
    port           = 22
  }
  ingress {
    protocol       = "TCP"
    description    = "HTTP to Elastic"
    v4_cidr_blocks = ["192.168.10.0/24"]
    port           = 9200
  }
  ingress {
    protocol       = "TCP"
    description    = "to logstash from beats"
    v4_cidr_blocks = ["192.168.11.0/24", "192.168.12.0/24"]
    port           = 5044
  }
  egress {
    protocol       = "TCP"
    description    = "All out"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group" "prometheussg" {
  name        = "prometheus-sg"
  description = "SG for prometheus"
  network_id  = "${yandex_vpc_network.network-netology.id}"
  ingress {
    protocol       = "TCP"
    description    = "SSH from bastion"
    v4_cidr_blocks = ["192.168.9.0/24"]
    port           = 22
  }
  ingress {
    protocol       = "TCP"
    description    = "HTTP from bastion"
    v4_cidr_blocks = ["192.168.9.0/24"]
    port           = 9090
  }
  ingress {
    protocol       = "TCP"
    description    = "HTTP in from grafana"
    v4_cidr_blocks = ["192.168.10.0/24"]
    port           = 9090
  }
  egress {
    protocol       = "TCP"
    description    = "All out"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

# БАЛАНСИРОВЩИКИ --------------------------------------------------------------------------------- //

resource "yandex_alb_target_group" "nginxtarget" {

  name      = "nginx-balancer"
  
  target {
    subnet_id  = "${yandex_vpc_subnet.subnet-nginx-one.id}"
    ip_address = "${yandex_compute_instance.nginx-one.network_interface.0.ip_address}"
  }

  target {
    subnet_id  = "${yandex_vpc_subnet.subnet-nginx-two.id}"
    ip_address = "${yandex_compute_instance.nginx-two.network_interface.0.ip_address}"
  }
}

resource "yandex_alb_backend_group" "netology-backend-group" {
  name                     = "netology-bg"

  http_backend {
    name                   = "nginx-backend"
    weight                 = 1
    port                   = 80
    target_group_ids       = [yandex_alb_target_group.nginxtarget.id]
    load_balancing_config {
      panic_threshold      = 90
    }    
    healthcheck {
      timeout              = "10s"
      interval             = "2s"
      healthy_threshold    = 10
      unhealthy_threshold  = 15 
      http_healthcheck {
        path               = "/"
      }
    }
  }
}

resource "yandex_alb_load_balancer" "netology-balancer" {
  name        = "nginx-balance"
  network_id  = yandex_vpc_network.network-netology.id

  allocation_policy {
    location {
      zone_id   = "ru-central1-a"
      subnet_id = yandex_vpc_subnet.subnet-nginx-one.id 
    }
    location {
      zone_id   = "ru-central1-b"
      subnet_id = yandex_vpc_subnet.subnet-nginx-two.id 
    }
  }

  listener {
    name = "nginx-listener"
    endpoint {
      address {
        external_ipv4_address {
          address = "158.160.15.11"
        }
      }
      ports = [ 80 ]
    }
    http {
      handler {
        http_router_id = yandex_alb_http_router.netology-router.id
      }
    }
  }
}

resource "yandex_alb_http_router" "netology-router" {
  name   = "netology-rt"
  labels = {
    tf-label    = "tf-label-value1"
    empty-label = ""
  }
}

resource "yandex_alb_virtual_host" "router-vh" {
  name           = "router-vh"
  http_router_id = yandex_alb_http_router.netology-router.id
  route {
    name = "nginx-rt"
    http_route {
      http_route_action {
        backend_group_id = yandex_alb_backend_group.netology-backend-group.id
        timeout          = "3s"
      }
    }
  }
} 

# ШЛЮЗЫ -----------------------------------------------------------------

resource "yandex_vpc_gateway" "nat_gateway" {
  name = "maingateway"
  shared_egress_gateway {}
}

resource "yandex_vpc_route_table" "rt-main" {
  name       = "main-route-table"
  network_id = yandex_vpc_network.network-netology.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id         = yandex_vpc_gateway.nat_gateway.id
  }
}

# OUTPUTS ---------------------------------------------------------------

output "internal_ip_address_bastion" {
  value = yandex_compute_instance.bastion.network_interface.0.ip_address
}
output "internal_ip_address_nginx-one" {
  value = yandex_compute_instance.nginx-one.network_interface.0.ip_address
}
output "internal_ip_address_nginx-two" {
  value = yandex_compute_instance.nginx-two.network_interface.0.ip_address
}
output "internal_ip_address_elasticsearch" {
  value = yandex_compute_instance.elasticsearch.network_interface.0.ip_address
}
output "internal_ip_address_kibana" {
  value = yandex_compute_instance.kibana.network_interface.0.ip_address
}
output "internal_ip_address_prometheus" {
  value = yandex_compute_instance.prometheus.network_interface.0.ip_address
}
output "internal_ip_address_grafana" {
  value = yandex_compute_instance.grafana.network_interface.0.ip_address
}

#resource "local_file" "hosts" {
#    content  = "foo!"
#    filename = "../ansible/hosts.txt"
#}