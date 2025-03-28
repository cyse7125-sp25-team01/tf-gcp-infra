output "external_ip" {
  value       = google_compute_address.static_ip.address
  description = "The external IP address for the load balancer"
}
