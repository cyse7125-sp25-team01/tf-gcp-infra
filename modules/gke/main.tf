data "google_project" "project" {}

resource "google_project_iam_member" "compute-system" {
  project = var.project_id
  role    = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member  = "serviceAccount:service-${data.google_project.project.number}@compute-system.iam.gserviceaccount.com"
}

resource "google_project_iam_member" "container-engine" {
  project = var.project_id
  role    = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member  = "serviceAccount:service-${data.google_project.project.number}@container-engine-robot.iam.gserviceaccount.com"
}

resource "google_service_account" "gke_node_sa" {
  account_id   = "gke-node-sa"
  display_name = "GKE Node Service Account"
}

resource "google_service_account" "k8s_workload_identity_sa" {
  account_id   = "k8s-workload-identity-sa"
  display_name = "Kubernetes Workload Identity Service Account"
}

resource "google_project_iam_member" "gcs_access" {
  project = var.project_id
  role    = "roles/storage.admin"
  member  = "serviceAccount:${google_service_account.k8s_workload_identity_sa.email}"
}

resource "google_project_iam_member" "secretmanager_access" {
  project = var.project_id
  role    = "roles/secretmanager.admin"
  member  = "serviceAccount:${google_service_account.k8s_workload_identity_sa.email}"
}
resource "google_project_iam_member" "service_account_token_creator" {
  project = var.project_id
  role    = "roles/iam.serviceAccountTokenCreator"
  member  = "serviceAccount:${google_service_account.k8s_workload_identity_sa.email}"
}

resource "google_iam_workload_identity_pool" "default" {
  project                   = var.project_id
  workload_identity_pool_id = "pool-${lower(replace(timestamp(), ":", "-"))}"
  display_name              = "Default Workload Identity Pool"
  description               = "Workload Identity Pool for GKE"
}


resource "google_service_account_iam_binding" "k8s_workload_identity_binding" {
  service_account_id = google_service_account.k8s_workload_identity_sa.id
  role               = "roles/iam.workloadIdentityUser"

  members = [
    "serviceAccount:${var.project_id}.svc.id.goog[default/gcs-sa]",
    "serviceAccount:${var.project_id}.svc.id.goog[default/sm-sa]",
    "serviceAccount:${var.project_id}.svc.id.goog[webapp/sm-sa]",
  ]

  depends_on = [
    google_iam_workload_identity_pool.default
  ]
}

resource "google_container_cluster" "private_gke_cluster" {
  name                     = var.cluster-name
  location                 = var.region
  initial_node_count       = 1
  deletion_protection      = false
  remove_default_node_pool = true
  min_master_version       = "1.30.9"
  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = true
    master_ipv4_cidr_block  = var.master_cidr_block
  }

  network    = var.vpc_network
  subnetwork = var.private_subnet

  # node_locations = [
  #   "${var.region}-d",
  #   "${var.region}-b",
  #   "${var.region}-c"
  # ]

  master_authorized_networks_config {
    cidr_blocks {
      cidr_block   = var.vpc_cidr
      display_name = "Master Network Config"
    }
  }

  database_encryption {
    state    = "ENCRYPTED"
    key_name = var.crypto_key_id
  }

  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  binary_authorization {
    evaluation_mode = "PROJECT_SINGLETON_POLICY_ENFORCE"
  }

  depends_on = [
    google_service_account.gke_node_sa
  ]
}

resource "google_container_node_pool" "pool_a" {
  name    = "node-pool-a"
  cluster = google_container_cluster.private_gke_cluster.id
  # node_count = 1
  location = "${var.region}-d"
  node_config {
    machine_type      = "e2-medium"
    disk_size_gb      = 15
    image_type        = "COS_CONTAINERD"
    tags              = ["private-instance"]
    service_account   = google_service_account.gke_node_sa.email
    oauth_scopes      = ["https://www.googleapis.com/auth/cloud-platform"]
    boot_disk_kms_key = var.crypto_key_id
  }
  initial_node_count = 1 # Ensures only 1 node per pool

  autoscaling {
    min_node_count = 1
    max_node_count = 1
  }
}

resource "google_container_node_pool" "pool_b" {
  name    = "node-pool-b"
  cluster = google_container_cluster.private_gke_cluster.id
  # node_count = 1
  location = "${var.region}-b"
  node_config {
    machine_type      = "e2-medium"
    disk_size_gb      = 15
    image_type        = "COS_CONTAINERD"
    tags              = ["private-instance"]
    service_account   = google_service_account.gke_node_sa.email
    oauth_scopes      = ["https://www.googleapis.com/auth/cloud-platform"]
    boot_disk_kms_key = var.crypto_key_id
  }
  initial_node_count = 1 # Ensures only 1 node per pool

  autoscaling {
    min_node_count = 1
    max_node_count = 1
  }
}

resource "google_container_node_pool" "pool_c" {
  name    = "node-pool-c"
  cluster = google_container_cluster.private_gke_cluster.id
  # node_count = 1
  location = "${var.region}-c"
  node_config {
    machine_type      = "e2-medium"
    disk_size_gb      = 15
    image_type        = "COS_CONTAINERD"
    tags              = ["private-instance"]
    service_account   = google_service_account.gke_node_sa.email
    oauth_scopes      = ["https://www.googleapis.com/auth/cloud-platform"]
    boot_disk_kms_key = var.crypto_key_id
  }
  initial_node_count = 1 # Ensures only 1 node per pool

  autoscaling {
    min_node_count = 1
    max_node_count = 1
  }
}
