variable "pubsub_topic_name" {
  description = "Name of the Pub/Sub topic for GCS notifications"
  type        = string
}

variable "pubsub_subscription_name" {
  description = "Name of the Pub/Sub subscription"
  type        = string
}

variable "bucket_name" {
  description = "Name of the GCS bucket for notifications"
  type        = string
  default     = "csye7125-trace-documents"
}
