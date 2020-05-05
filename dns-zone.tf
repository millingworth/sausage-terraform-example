resource "openstack_dns_zone_v2" "zone_cloud_mattillingworth_com" {
    lifecycle {
            prevent_destroy = true
            ignore_changes = all
    }
  name = "cloud.mattillingworth.com."
  email = "matt@sausage.systems"
  ttl = 3600
  type = "PRIMARY"
}
