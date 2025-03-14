resource "google_dns_record_set" "a_record" {
  name = "${var.dns_name}."
  # name         = "dev.gcp.csye7125-team01.store."
  type         = "A"
  ttl          = 60
  managed_zone = var.dns_zone_name
  # managed_zone = "dev-gcp-csye7125-team01"
  # rrdatas      = [module.external_ip.external_ip]
  rrdatas = [var.external_ip]
}
