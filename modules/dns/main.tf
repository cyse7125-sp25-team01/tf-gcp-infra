resource "google_dns_managed_zone" "public_zone" {
  name        = var.dns_name
  dns_name    = "${var.dns_zone_name}."
  description = "Public hosted zone for ${var.dns_zone_name}"
  visibility  = "public"
}
