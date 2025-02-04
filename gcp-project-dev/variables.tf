variable "region" {
  description = "Region "
  type        = string
}
variable "credfile" {
  description = "Location of the Cred File "
  type        = string
}

variable "gcs_bucket_name" {
  description = "GCS bucket for Terraform state"
  type        = string
}


variable "project_id" {
  description = "Project ID "
  type        = string
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
}

variable "vpc_name" {
  description = "The name of the VPC"
  type        = string
}

variable "destination_cidr" {
  description = "The destination CIDR for the route"
  type        = string
}
