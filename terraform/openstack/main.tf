# PROVIDER
provider "openstack" {
  user_name   = "${var.os_user}"
  password    = "${var.os_pass}"
  tenant_name = "${var.tenant}"
  auth_url    = "${var.os_auth_url}"
  domain_name = "Default"
}

# Security Groups
resource "openstack_networking_secgroup_v2" "microservice_sec_group" {
  name        = "microservices"
  description = "Standard security group for microservices"
}

resource "openstack_networking_secgroup_rule_v2" "ms_ssh" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.microservice_sec_group.id}"
}

resource "openstack_networking_secgroup_rule_v2" "ms_https" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 443
  port_range_max    = 443
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.microservice_sec_group.id}"
}

resource "openstack_networking_secgroup_rule_v2" "ms_http" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 80
  port_range_max    = 80
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.microservice_sec_group.id}"
}

resource "openstack_networking_secgroup_rule_v2" "ms_http_user" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 8080
  port_range_max    = 8080
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.microservice_sec_group.id}"
}

resource "openstack_networking_secgroup_rule_v2" "ms_https_user" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 8443
  port_range_max    = 8443
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.microservice_sec_group.id}"
}

# Compute

# Jenkins Slave
# 8CPU 16GB
resource "openstack_compute_instance_v2" "jenkins_slave" {
  name            = "jenkins-slave"
  image_id        = "${var.ubuntu_18}"
  flavor_id       = "${var.medium}"
  key_pair        = "dusan"
  security_groups = ["default", "${openstack_networking_secgroup_v2.microservice_sec_group.id}"]

  metadata {
    app = "jenkins"
  }

  network {
    name = "sweng-dev-net"
  }
}

resource "openstack_compute_floatingip_associate_v2" "jenkins_ip" {
  floating_ip = "10.30.134.32"
  instance_id = "${openstack_compute_instance_v2.jenkins_slave.id}"
}

# Portal Dev
resource "openstack_compute_instance_v2" "dcc_portal_dev" {
  name            = "dcc-portal-dev"
  image_id        = "${var.ubuntu_18}"
  flavor_id       = "${var.medium}"
  key_pair        = "dusan"
  security_groups = ["default", "${openstack_networking_secgroup_v2.microservice_sec_group.id}"]

  metadata {
    app = "dcc-dev"
  }

  network {
    name = "sweng-dev-net"
  }
}

resource "openstack_compute_floatingip_associate_v2" "dcc_portal_dev_ip" {
  floating_ip = "10.30.134.33"
  instance_id = "${openstack_compute_instance_v2.dcc_portal_dev.id}"
}

# Portal Staging
resource "openstack_compute_instance_v2" "dcc_portal_staging" {
  name            = "dcc-portal-staging"
  image_id        = "${var.ubuntu_18}"
  flavor_id       = "${var.small}"
  key_pair        = "dusan"
  security_groups = ["default", "${openstack_networking_secgroup_v2.microservice_sec_group.id}"]

  metadata {
    app = "dcc-portal"
  }

  network {
    name = "sweng-dev-net"
  }
}

resource "openstack_compute_floatingip_associate_v2" "dcc_portal_staging_ip" {
  floating_ip = "10.30.134.34"
  instance_id = "${openstack_compute_instance_v2.dcc_portal_staging.id}"
}

# Elasticsearch Cluster
resource "openstack_compute_instance_v2" "dcc_elasticsearch" {
  name            = "dcc-elasticsearch-${count.index}"
  image_id        = "${var.ubuntu_18}"
  flavor_id       = "${var.xlarge}"
  key_pair        = "dusan"
  security_groups = ["default", "${openstack_networking_secgroup_v2.microservice_sec_group.id}"]
  count           = 10

  metadata {
    app = "dcc-elasticsearch"
  }

  network {
    name = "sweng-dev-net"
  }
}

resource "openstack_compute_floatingip_associate_v2" "dcc_elasticsearch0_ip" {
  floating_ip = "10.30.134.10"
  instance_id = "${openstack_compute_instance_v2.dcc_elasticsearch.0.id}"
}

resource "openstack_compute_floatingip_associate_v2" "dcc_elasticsearch1_ip" {
  floating_ip = "10.30.134.11"
  instance_id = "${openstack_compute_instance_v2.dcc_elasticsearch.1.id}"
}

resource "openstack_compute_floatingip_associate_v2" "dcc_elasticsearch2_ip" {
  floating_ip = "10.30.134.12"
  instance_id = "${openstack_compute_instance_v2.dcc_elasticsearch.2.id}"
}

resource "openstack_compute_floatingip_associate_v2" "dcc_elasticsearch3_ip" {
  floating_ip = "10.30.134.13"
  instance_id = "${openstack_compute_instance_v2.dcc_elasticsearch.3.id}"
}

resource "openstack_compute_floatingip_associate_v2" "dcc_elasticsearch4_ip" {
  floating_ip = "10.30.134.14"
  instance_id = "${openstack_compute_instance_v2.dcc_elasticsearch.4.id}"
}

resource "openstack_compute_floatingip_associate_v2" "dcc_elasticsearch5_ip" {
  floating_ip = "10.30.134.15"
  instance_id = "${openstack_compute_instance_v2.dcc_elasticsearch.5.id}"
}

resource "openstack_compute_floatingip_associate_v2" "dcc_elasticsearch6_ip" {
  floating_ip = "10.30.134.16"
  instance_id = "${openstack_compute_instance_v2.dcc_elasticsearch.6.id}"
}

resource "openstack_compute_floatingip_associate_v2" "dcc_elasticsearch7_ip" {
  floating_ip = "10.30.134.17"
  instance_id = "${openstack_compute_instance_v2.dcc_elasticsearch.7.id}"
}

resource "openstack_compute_floatingip_associate_v2" "dcc_elasticsearch8_ip" {
  floating_ip = "10.30.134.18"
  instance_id = "${openstack_compute_instance_v2.dcc_elasticsearch.8.id}"
}

resource "openstack_compute_floatingip_associate_v2" "dcc_elasticsearch9_ip" {
  floating_ip = "10.30.134.19"
  instance_id = "${openstack_compute_instance_v2.dcc_elasticsearch.9.id}"
}
