# locals.tf
locals {
  public_subnet_count  = 1
  private_subnet_count = 1

  public_subnet_cidrs = [
    for i in range(0, local.public_subnet_count) : cidrsubnet(var.vpc_cidr, 8, i)
  ]

  private_subnet_cidrs = [
    for i in range(0, local.private_subnet_count) : cidrsubnet(var.vpc_cidr, 8, local.public_subnet_count + i)
  ]

  master_cidr_block = cidrsubnet(var.vpc_cidr, 12, local.public_subnet_count + local.private_subnet_count + 94)

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

#Allow SSH (port 22) for inbound access to public instances
resource "google_compute_firewall" "allow_ssh" {
  name    = "${var.vpc_name}-allow-ssh"
  network = google_compute_network.app_vpc.id

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["public-instance", "bastion"]
}

# Allow HTTP (port 80) and HTTPS (port 443) 
resource "google_compute_firewall" "allow_http_https" {
  name    = "${var.vpc_name}-allow-http-https"
  network = google_compute_network.app_vpc.id

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["public-instance"]
}

# Allow outbound HTTP/HTTPS traffic from private instances via NAT gateway
resource "google_compute_firewall" "allow_private_outbound" {
  name    = "${var.vpc_name}-allow-private-outbound"
  network = google_compute_network.app_vpc.id

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  source_ranges = local.private_subnet_cidrs
  target_tags   = ["private-instance"]
}

# Allow internal traffic between public and private subnets
resource "google_compute_firewall" "allow_internal_traffic" {
  name    = "${var.vpc_name}-allow-internal-traffic"
  network = google_compute_network.app_vpc.id

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  source_ranges = local.private_subnet_cidrs
  target_tags   = ["public-instance", "private-instance"]
}

#rule to allow access to the GKE node pool
resource "google_compute_firewall" "allow_bastion_to_gke_nodes" {
  name    = "${var.vpc_name}-allow-bastion-to-gke-nodes"
  network = google_compute_network.app_vpc.id

  allow {
    protocol = "tcp"
    ports    = ["443", "10250"]
  }

  source_tags = ["bastion"]
  target_tags = ["private-instance"]
}
