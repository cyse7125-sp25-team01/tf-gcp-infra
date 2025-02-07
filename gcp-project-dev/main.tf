terraform {
  backend "gcs" {}
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

module "bastion" {
  source           = "../modules/bastion"
  region           = var.region
  ssh_public_key   = var.bastion_ssh_public_key
  name             = var.bastion_name
  os               = var.bastion_os
  machine_type     = var.bastion_machine_type
  public_subnet_id = module.vpc.public_subnet_ids[0]
  project_id       = var.project_id
  cluster-name     = var.cluster-name
  depends_on = [
    module.gke
  ]
}
module "gke" {
  source            = "../modules/gke"
  region            = var.region
  vpc_network       = module.vpc.vpc_id
  private_subnet    = module.vpc.private_subnet_ids[0]
  master_cidr_block = module.vpc.master_subnet_cidrs
  vpc_cidr          = var.vpc_cidr
  public_subnet     = module.vpc.public_subnet_ids[0]
  cluster-name      = var.cluster-name
  project_id        = var.project_id
}

