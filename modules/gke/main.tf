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

# resource "google_project_iam_member" "container-engine-sa" {
#   project = var.project_id
#   role    = "roles/container.serviceAgent"
#   member  = "serviceAccount:service-${data.google_project.project.number}@container-engine-robot.iam.gserviceaccount.com"
# }

resource "google_service_account" "gke_node_sa" {
  account_id   = "gke-node-sa"
  display_name = "GKE Node Service Account"
}

resource "google_service_account" "k8s_workload_identity_sa" {
  account_id   = "k8s-workload-identity-sa"
  display_name = "Kubernetes Workload Identity Service Account"
}

resource "google_project_iam_member" "gke_node_monitoring" {
  project = var.project_id
  role    = "roles/monitoring.admin"
  member  = "serviceAccount:${google_service_account.gke_node_sa.email}"
}



resource "google_project_iam_member" "gke_node_logging" {
  project = var.project_id
  role    = "roles/logging.admin"
  member  = "serviceAccount:${google_service_account.gke_node_sa.email}"
}

resource "google_project_iam_member" "gcs_access" {
  project = var.project_id
  role    = "roles/storage.admin"
  member  = "serviceAccount:${google_service_account.k8s_workload_identity_sa.email}"
}

resource "google_project_iam_member" "pubsub_admin" {
  project = var.project_id
  role    = "roles/pubsub.admin"
  member  = "serviceAccount:${google_service_account.k8s_workload_identity_sa.email}"
}

resource "google_project_iam_member" "dns_access" {
  project = var.project_id
  role    = "roles/dns.admin"
  member  = "serviceAccount:${google_service_account.k8s_workload_identity_sa.email}"
}

resource "google_project_iam_member" "cloudtrace_admin" {
  project = var.project_id
  role    = "roles/cloudtrace.admin"
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
    "serviceAccount:${var.project_id}.svc.id.goog[external-dns/external-dns]",
    "serviceAccount:${var.project_id}.svc.id.goog[monitoring/otel-collector-sa]",
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

  monitoring_config {
    enable_components = [
      "SYSTEM_COMPONENTS",
      "DEPLOYMENT",
      "APISERVER",
      "SCHEDULER",
      "CONTROLLER_MANAGER",
      "STORAGE"
    ]

    managed_prometheus {
      enabled = true
    }
  }

  # Add logging configuration
  logging_config {
    enable_components = [
      "SYSTEM_COMPONENTS",
      "WORKLOADS"
    ]
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
    machine_type      = "e2-standard-2"
    disk_size_gb      = 50
    image_type        = "COS_CONTAINERD"
    tags              = ["private-instance"]
    service_account   = google_service_account.gke_node_sa.email
    oauth_scopes      = ["https://www.googleapis.com/auth/cloud-platform"]
    boot_disk_kms_key = var.crypto_key_id
    labels = {
      "pool" = "a"
    }
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
    machine_type      = "e2-standard-2"
    disk_size_gb      = 50
    image_type        = "COS_CONTAINERD"
    tags              = ["private-instance"]
    service_account   = google_service_account.gke_node_sa.email
    oauth_scopes      = ["https://www.googleapis.com/auth/cloud-platform"]
    boot_disk_kms_key = var.crypto_key_id
    labels = {
      "pool" = "b"
    }
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
    machine_type      = "e2-standard-2"
    disk_size_gb      = 50
    image_type        = "COS_CONTAINERD"
    tags              = ["private-instance"]
    service_account   = google_service_account.gke_node_sa.email
    oauth_scopes      = ["https://www.googleapis.com/auth/cloud-platform"]
    boot_disk_kms_key = var.crypto_key_id
    labels = {
      "pool" = "c"
    }
  }

  initial_node_count = 1 # Ensures only 1 node per pool

  autoscaling {
    min_node_count = 1
    max_node_count = 1
  }
}

resource "google_monitoring_dashboard" "cert_manager_external_dns_dashboard" {
  dashboard_json = <<EOF
{
  "displayName": "Cert-Manager and External-DNS Dashboard Grafana",
  "dashboardFilters": [],
  "gridLayout": {
    "columns": "2",
    "widgets": [
      {
        "title": "Certmanager certificate expiration timestamp seconds",
        "scorecard": {
          "gaugeView": {
            "lowerBound": 0,
            "upperBound": 1
          },
          "thresholds": [],
          "timeSeriesQuery": {
            "outputFullDuration": true,
            "timeSeriesFilter": {
              "aggregation": {
                "alignmentPeriod": "60s",
                "crossSeriesReducer": "REDUCE_SUM",
                "groupByFields": [],
                "perSeriesAligner": "ALIGN_MEAN"
              },
              "filter": "metric.type=\"prometheus.googleapis.com/certmanager_certificate_expiration_timestamp_seconds/gauge\" resource.type=\"prometheus_target\""
            }
          }
        }
      },
      {
        "title": "Certmanager certificate ready status",
        "scorecard": {
          "thresholds": [],
          "timeSeriesQuery": {
            "outputFullDuration": true,
            "timeSeriesFilter": {
              "aggregation": {
                "alignmentPeriod": "60s",
                "crossSeriesReducer": "REDUCE_SUM",
                "groupByFields": [],
                "perSeriesAligner": "ALIGN_MEAN"
              },
              "filter": "metric.type=\"prometheus.googleapis.com/certmanager_certificate_ready_status/gauge\" resource.type=\"prometheus_target\""
            }
          }
        }
      },
      {
        "title": "Certmanager certificate renewal timestamp seconds",
        "timeSeriesTable": {
          "columnSettings": [],
          "dataSets": [
            {
              "minAlignmentPeriod": "60s",
              "timeSeriesQuery": {
                "outputFullDuration": true,
                "timeSeriesFilter": {
                  "aggregation": {
                    "crossSeriesReducer": "REDUCE_SUM",
                    "groupByFields": [],
                    "perSeriesAligner": "ALIGN_MEAN"
                  },
                  "filter": "metric.type=\"prometheus.googleapis.com/certmanager_certificate_renewal_timestamp_seconds/gauge\" resource.type=\"prometheus_target\""
                }
              }
            }
          ],
          "metricVisualization": "NUMBER"
        }
      },
      {
        "title": "Certmanager http acme client request count",
        "scorecard": {
          "blankView": {},
          "thresholds": [],
          "timeSeriesQuery": {
            "outputFullDuration": true,
            "timeSeriesFilter": {
              "aggregation": {
                "alignmentPeriod": "60s",
                "crossSeriesReducer": "REDUCE_SUM",
                "groupByFields": [],
                "perSeriesAligner": "ALIGN_RATE"
              },
              "filter": "metric.type=\"prometheus.googleapis.com/certmanager_http_acme_client_request_count/counter\" resource.type=\"prometheus_target\""
            }
          }
        }
      },
      {
        "title": "External DNS Registry A Records",
        "timeSeriesTable": {
          "columnSettings": [],
          "dataSets": [
            {
              "minAlignmentPeriod": "60s",
              "timeSeriesQuery": {
                "outputFullDuration": true,
                "timeSeriesFilter": {
                  "aggregation": {
                    "crossSeriesReducer": "REDUCE_SUM",
                    "groupByFields": [],
                    "perSeriesAligner": "ALIGN_MEAN"
                  },
                  "filter": "metric.type=\"prometheus.googleapis.com/external_dns_registry_a_records/gauge\" resource.type=\"prometheus_target\""
                }
              }
            }
          ],
          "metricVisualization": "NUMBER"
        }
      },
      {
        "title": "Cert Manager logs",
        "logsPanel": {
          "filter": "",
          "resourceNames": [
            "projects/${var.project_id}/locations/global/logScopes/_Default"
          ]
        }
      },
      {
        "title": "External DNS Controller Verified A Records",
        "timeSeriesTable": {
          "columnSettings": [],
          "dataSets": [
            {
              "minAlignmentPeriod": "60s",
              "timeSeriesQuery": {
                "outputFullDuration": true,
                "timeSeriesFilter": {
                  "aggregation": {
                    "crossSeriesReducer": "REDUCE_SUM",
                    "groupByFields": [],
                    "perSeriesAligner": "ALIGN_MEAN"
                  },
                  "filter": "metric.type=\"prometheus.googleapis.com/external_dns_controller_verified_a_records/gauge\" resource.type=\"prometheus_target\"",
                  "pickTimeSeriesFilter": {
                    "direction": "TOP",
                    "numTimeSeries": 30,
                    "rankingMethod": "METHOD_MEAN"
                  }
                }
              }
            }
          ],
          "metricVisualization": "BAR"
        }
      },
      {
        "title": "External dns source a records",
        "scorecard": {
          "blankView": {},
          "thresholds": [],
          "timeSeriesQuery": {
            "outputFullDuration": true,
            "timeSeriesFilter": {
              "aggregation": {
                "alignmentPeriod": "60s",
                "crossSeriesReducer": "REDUCE_SUM",
                "groupByFields": [],
                "perSeriesAligner": "ALIGN_MEAN"
              },
              "filter": "metric.type=\"prometheus.googleapis.com/external_dns_source_a_records/gauge\" resource.type=\"prometheus_target\""
            }
          }
        }
      },
      {
        "title": "External DNS Logs",
        "logsPanel": {
          "filter": "",
          "resourceNames": [
            "projects/${var.project_id}/locations/global/logScopes/_Default"
          ]
        }
      }
    ]
  }
}
EOF
}
