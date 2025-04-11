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

module "cmek" {
  source     = "../modules/cmek"
  project_id = var.project_id
  region     = var.region
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
  crypto_key_id     = module.cmek.gke_crypto_key_id
}

# module "external_ip" {
#   source     = "../modules/external_ip"
#   region     = var.region
#   project_id = var.project_id
# }

module "sm" {
  source            = "../modules/secretmanager"
  region            = var.region
  postgres_password = var.postgres_password
  secret_name       = var.secret_name
  dockerhub-secret  = var.dockerhub-secret
}

# module "dns_record" {
#   source        = "../modules/dns"
#   dns_name      = var.dns_name
#   dns_zone_name = var.dns_zone_name
#   external_ip   = module.external_ip.external_ip
# }

module "gcs" {
  source      = "../modules/gcs"
  region      = var.region
  bucket_name = var.bucket_name
}

module "pubsub" {
  source                   = "../modules/pubsub"
  bucket_name              = var.bucket_name
  pubsub_topic_name        = var.pubsub_topic_name
  pubsub_subscription_name = var.pubsub_subscription_name
}
