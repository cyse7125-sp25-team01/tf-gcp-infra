resource "google_secret_manager_secret" "password" {
  secret_id = var.secret_name
  replication {
    user_managed {
      replicas {
        location = var.region
      }
    }

  }
}

resource "google_secret_manager_secret_version" "password_version" {
  secret = google_secret_manager_secret.password.id

  secret_data = var.postgres_password
}
