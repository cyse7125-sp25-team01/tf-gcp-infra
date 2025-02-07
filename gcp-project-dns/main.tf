# terraform init -backend-config=backend.tfvars

terraform {
  backend "gcs" {}
}

provider "google" {
  project     = var.project_id
  region      = var.region
  credentials = var.credfile


module "public_hosted_zone_dev" {
  source        = "../modules/dns"
  dns_name      = var.dns_name_dev
  dns_zone_name = var.dns_zone_name_dev
}

module "public_hosted_zone_prd" {
  source        = "../modules/dns"
  dns_name      = var.dns_name_prd
  dns_zone_name = var.dns_zone_name_prd
}
