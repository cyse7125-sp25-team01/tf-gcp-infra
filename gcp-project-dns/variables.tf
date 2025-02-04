variable "region" {
  description = "Region "
  type        = string
}

variable "dns_zone_name" {
  description = "The name of the DNS zone "
  type        = string
}

variable "dns_name" {
  description = "DNS Name "
  type        = string
}

variable "credfile" {
  description = "Location of the Cred File "
  type        = string
}

variable "project_id" {
  description = "Project ID "
  type        = string
}

variable "gcs_bucket_name" {
  description = "GCS bucket for Terraform state"
  type        = string
}

