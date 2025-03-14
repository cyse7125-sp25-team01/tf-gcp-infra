# terraform init -backend-config=backend.tfvars

terraform {
  backend "gcs" {}
}

provider "google" {
  alias       = "dns"
  project     = var.project_id
  region      = var.region
  credentials = var.credfile
}

provider "google" {
  alias       = "dev"
  project     = var.project_id_dev
  region      = var.region
  credentials = var.credfile_dev
}

provider "google" {
  alias       = "prd"
  project     = var.project_id_prd
  region      = var.region
  credentials = var.credfile_prd
}

resource "google_dns_managed_zone" "public_zone" {
  provider    = google.dns
  name        = var.dns_zone_name
  dns_name    = "${var.dns_name}."
  description = "Public hosted zone for ${var.dns_zone_name}"
  visibility  = "public"
}


resource "google_dns_managed_zone" "dev_zone" {
  provider = google.dev
  name     = "${var.dns_zone_name_dev}"
  dns_name = "${var.dns_name_dev}."
  description = "Public hosted zone for ${var.dns_zone_name_dev}"
  visibility  = "public"
}

resource "google_dns_record_set" "dev_delegation" {
  provider     = google.dns
  managed_zone = google_dns_managed_zone.public_zone.name
  name         = "${var.dns_name_dev}."
  type         = "NS"
  ttl          = 60
  rrdatas      = google_dns_managed_zone.dev_zone.name_servers
}

resource "google_dns_managed_zone" "prd_zone" {
  provider = google.prd
  name     = "${var.dns_zone_name_prd}"
  dns_name = "${var.dns_name_prd}."
  description = "Public hosted zone for ${var.dns_zone_name_prd}"
  visibility  = "public"
 }

resource "google_dns_record_set" "prd_delegation" {
  provider     = google.dns
  managed_zone = google_dns_managed_zone.public_zone.name
  name         = "${var.dns_name_prd}."
  type         = "NS"
  ttl          = 60
  rrdatas      = google_dns_managed_zone.prd_zone.name_servers
}

