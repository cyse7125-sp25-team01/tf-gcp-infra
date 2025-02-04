# locals.tf
locals {
  public_subnet_count  = 3
  private_subnet_count = 3

  public_subnet_cidrs = [
    for i in range(0, local.public_subnet_count) : cidrsubnet(var.vpc_cidr, 8, i)
  ]

  private_subnet_cidrs = [
    for i in range(0, local.private_subnet_count) : cidrsubnet(var.vpc_cidr, 8, local.public_subnet_count + i)
  ]
}

resource "google_compute_network" "app_vpc" {
  name                    = var.vpc_name
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"
}

resource "google_compute_subnetwork" "public_subnet" {
  count         = local.public_subnet_count
  name          = "${var.vpc_name}-public-${count.index + 1}"
  ip_cidr_range = local.public_subnet_cidrs[count.index]
  network       = google_compute_network.app_vpc.id
  region        = var.region
}


resource "google_compute_subnetwork" "private_subnet" {
  count         = local.private_subnet_count
  name          = "${var.vpc_name}-private-${count.index + 1}"
  ip_cidr_range = local.private_subnet_cidrs[count.index]
  network       = google_compute_network.app_vpc.id
  region        = var.region
}

resource "google_compute_route" "public_route" {
  name             = "${var.vpc_name}-public-route"
  dest_range       = var.destination_cidr
  network          = google_compute_network.app_vpc.id
  next_hop_gateway = "default-internet-gateway"
  priority         = 100
}

resource "google_compute_router" "private_router" {
  name    = "${var.vpc_name}-private-router"
  network = google_compute_network.app_vpc.id
  region  = var.region
}

resource "google_compute_router_nat" "private_nat" {
  name                               = "${var.vpc_name}-private-nat"
  router                             = google_compute_router.private_router.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

  subnetwork {
    name                    = google_compute_subnetwork.private_subnet[0].id
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }
}