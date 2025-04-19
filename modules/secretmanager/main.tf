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

resource "google_secret_manager_secret" "dockerhub-secret" {
  secret_id = "dockerhub-secret"
  replication {
    user_managed {
      replicas {
        location = var.region
      }
    }

  }
}

resource "google_secret_manager_secret_version" "dockerhub-secret_version" {
  secret = google_secret_manager_secret.dockerhub-secret.id

  secret_data = var.dockerhub-secret
}

resource "google_secret_manager_secret" "openapi-key" {
  secret_id = "openapi-key"
  replication {
    user_managed {
      replicas {
        location = var.region
      }
    }

  }
}

resource "google_secret_manager_secret_version" "openapi-key_version" {
  secret = google_secret_manager_secret.openapi-key.id

  secret_data = var.openapi-key
}

resource "google_secret_manager_secret" "pineconeapi-key" {
  secret_id = "pineconeapi-key"
  replication {
    user_managed {
      replicas {
        location = var.region
      }
    }

  }
}

resource "google_secret_manager_secret_version" "pineconeapi-key_version" {
  secret = google_secret_manager_secret.pineconeapi-key.id

  secret_data = var.pineconeapi-key
}
