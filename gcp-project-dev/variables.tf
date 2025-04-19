variable "region" {
  description = "Region "
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

variable "bastion_ssh_public_key" {
  description = "The SSH public key for accessing the bastion host."
  type        = string
}

variable "bastion_name" {
  description = "Name of the Bastion "
  type        = string
}

variable "bastion_machine_type" {
  description = "Machine type of the Instance "
  type        = string
}

variable "bastion_os" {
  description = "OS of the instance "
  type        = string
}

variable "cluster-name" {
  description = "Name of the cluster"
  type        = string
}
variable "postgres_password" {
  description = "Postgres password"
  type        = string
}
variable "dockerhub-secret" {
  description = "Dockerhub secret"
  type        = string
}


variable "secret_name" {
  description = "Secret Name"
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

variable "bucket_name" {
  description = "Bucket Name"
  type        = string
}

variable "pubsub_topic_name" {
  description = "Name of the Pub/Sub topic for GCS notifications"
  type        = string
}

variable "pubsub_subscription_name" {
  description = "Name of the Pub/Sub subscription"
  type        = string
}

variable "openapi-key" {
  description = "Openapi key secret"
  type        = string
}

variable "pineconeapi-key" {
  description = "Pinecone api secret"
  type        = string
}
