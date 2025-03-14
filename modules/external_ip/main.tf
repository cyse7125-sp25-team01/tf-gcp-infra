resource "google_compute_global_address" "static_ip" {
  name    = "loadbalancer-k8s"
  project = var.project_id
  # region       = var.region
  address_type = "EXTERNAL"
}
