output "gke_key_ring_id" {
  description = "The ID of the KMS Key Ring"
  value       = google_kms_key_ring.gke_key_ring.id
}

output "gke_key_ring_name" {
  description = "The name of the KMS Key Ring"
  value       = google_kms_key_ring.gke_key_ring.name
}

output "gke_crypto_key_id" {
  description = "The ID of the KMS Crypto Key"
  value       = google_kms_crypto_key.gke_crypto_key.id
}

output "gke_crypto_key_name" {
  description = "The Name of the KMS Crypto Key"
  value       = google_kms_crypto_key.gke_crypto_key.name
}

output "gke_crypto_key_full_path" {
  description = "The fully qualified KMS Crypto Key path"
  value       = "projects/${var.project_id}/locations/${var.region}/keyRings/${google_kms_key_ring.gke_key_ring.name}/cryptoKeys/${google_kms_crypto_key.gke_crypto_key.name}"
}
