resource "google_pubsub_topic" "gcs_notifications" {
  name = var.pubsub_topic_name
}

resource "google_pubsub_subscription" "gcs_subscription" {
  name  = var.pubsub_subscription_name
  topic = google_pubsub_topic.gcs_notifications.name

  ack_deadline_seconds = 60
}

# Get the Google Cloud Storage service account
data "google_storage_project_service_account" "gcs_account" {}

# Grant the service account permission to publish to the topic
resource "google_pubsub_topic_iam_binding" "binding" {
  topic   = google_pubsub_topic.gcs_notifications.id
  role    = "roles/pubsub.publisher"
  members = ["serviceAccount:${data.google_storage_project_service_account.gcs_account.email_address}"]
}

# Create the notification configuration - explicitly depend on the IAM binding
resource "google_storage_notification" "notification" {
  bucket         = var.bucket_name
  payload_format = "JSON_API_V1"
  topic          = google_pubsub_topic.gcs_notifications.id

  # Explicitly depend on both the topic and the IAM binding
  depends_on = [
    google_pubsub_topic.gcs_notifications,
    google_pubsub_topic_iam_binding.binding
  ]
}
