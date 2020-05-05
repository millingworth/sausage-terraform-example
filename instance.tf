resource "openstack_compute_instance_v2" "example1" {
  name            = "example1"
  image_name      = "Ubuntu 18.04"
  config_drive    = true
  user_data       = "${file("firstboot.sh")}"
  flavor_name     = "chipolata"
  key_pair        = "${openstack_compute_keypair_v2.matt_illingworth_key.name}"
  security_groups = ["default","allow_admin"]

  network {
    name = "direct_internet"
  }
}

resource "openstack_dns_recordset_v2" "rs_example1" {
  zone_id = "${openstack_dns_zone_v2.zone_sausage_systems.id}"
  name = "example1.cloud.mattillingworth.com."
  description = "example1 record"
  ttl = 3600
  type = "A"
  records = ["${openstack_compute_instance_v2.meat.access_ip_v4}"]
}
