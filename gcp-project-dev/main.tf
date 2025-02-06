terraform {
  backend "gcs" {
    bucket = "terraform-state-csye7125-dev"
  }
}

provider "google" {
  project     = var.project_id
  region      = var.region
  credentials = var.credfile
}

module "vpc" {
  source           = "../modules/vpc"
  region           = var.region
  vpc_cidr         = var.vpc_cidr
  vpc_name         = var.vpc_name
  destination_cidr = var.destination_cidr
}