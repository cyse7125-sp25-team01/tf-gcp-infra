output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = google_compute_subnetwork.public_subnet[*].id
}

output "public_subnet_cidrs" {
  description = "CIDR blocks of the public subnets"
  value       = local.public_subnet_cidrs
}

output "master_subnet_cidrs" {
  description = "CIDR blocks of the Master CIDR"
  value       = local.master_cidr_block
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = google_compute_subnetwork.private_subnet[*].id
}

output "private_subnet_cidrs" {
  description = "CIDR blocks of the private subnets"
  value       = local.private_subnet_cidrs
}

output "vpc_id" {
  description = "ID of the created VPC"
  value       = google_compute_network.app_vpc.id
}

output "public_route_id" {
  description = "ID of the public route"
  value       = google_compute_route.public_route.id
}

output "private_router_id" {
  description = "ID of the private router"
  value       = google_compute_router.private_router.id
}

output "private_nat_id" {
  description = "ID of the private NAT gateway"
  value       = google_compute_router_nat.private_nat.id
}

output "firewall_ssh_id" {
  description = "ID of the SSH firewall rule"
  value       = google_compute_firewall.allow_ssh.id
}

output "firewall_http_https_id" {
  description = "ID of the HTTP/HTTPS firewall rule"
  value       = google_compute_firewall.allow_http_https.id
}

output "firewall_private_outbound_id" {
  description = "ID of the private outbound firewall rule"
  value       = google_compute_firewall.allow_private_outbound.id
}

output "firewall_internal_traffic_id" {
  description = "ID of the internal traffic firewall rule"
  value       = google_compute_firewall.allow_internal_traffic.id
}
