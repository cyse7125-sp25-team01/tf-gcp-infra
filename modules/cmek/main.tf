resource "google_kms_key_ring" "gke_key_ring" {
  name     = "gke-key-ring-${lower(replace(timestamp(), ":", "-"))}"
  location = var.region
  project  = var.project_id
}

resource "google_kms_crypto_key" "gke_crypto_key" {
  name            = "gke-crypto-key"
  key_ring        = google_kms_key_ring.gke_key_ring.id
  rotation_period = "100000s"
  purpose         = "ENCRYPT_DECRYPT"
  version_template {
    algorithm        = "GOOGLE_SYMMETRIC_ENCRYPTION"
    protection_level = "SOFTWARE"
  }
}
