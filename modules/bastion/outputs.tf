output "bastion_external_ip" {
  value = google_compute_instance.bastion_host.network_interface[0].access_config[0].nat_ip
}
output "bastion_private_ip" {
  value       = google_compute_instance.bastion_host.network_interface[0].network_ip
  description = "Private IP address of the Bastion Host"
}
