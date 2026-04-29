resource "yandex_dns_recordset" "app_a_record" {
  zone_id = var.dns_zone_id
  name    = "${var.app_domain}."
  type    = "A"
  ttl     = 300
  data    = [one(yandex_alb_load_balancer.web.listener).endpoint[0].address[0].external_ipv4_address[0].address]
}
