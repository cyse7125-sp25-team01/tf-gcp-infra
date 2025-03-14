resource "google_service_account" "bastion_sa" {
  account_id   = "bastion-sa"
  display_name = "Bastion Host Service Account"
}

resource "google_project_iam_member" "bastion_sa_kubernetes_admin" {
  project = var.project_id
  role    = "roles/container.admin"
  member  = "serviceAccount:${google_service_account.bastion_sa.email}"
}

resource "google_compute_instance" "bastion_host" {
  name         = var.name
  machine_type = var.machine_type
  zone         = "${var.region}-b"

  tags = ["public-instance", "bastion"]

  boot_disk {
    initialize_params {
      image = var.os
    }
  }

  network_interface {
    subnetwork = var.public_subnet_id

    access_config {
      network_tier = "STANDARD"
    }
  }

  service_account {
    email  = google_service_account.bastion_sa.email
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }

  metadata = {
    ssh-keys = "ubuntu:${var.ssh_public_key}"
  }

  metadata_startup_script = <<SCRIPT
      curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg
      echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
      sudo apt-get update -y
      sudo apt-get install google-cloud-cli -y 
      sudo apt-get install google-cloud-sdk-gke-gcloud-auth-plugin -y
      sudo apt-get install kubectl -y
      echo "gcloud container clusters get-credentials ${var.cluster-name} --region ${var.region} --project ${var.project_id}" >> /etc/profile
      curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
      chmod 700 get_helm.sh
      ./get_helm.sh
      helm repo add external-secrets https://charts.external-secrets.io
      helm install external-secrets external-secrets/external-secrets
    SCRIPT


  # depends_on = [
  #   var.public_subnet_id
  # ]
}

