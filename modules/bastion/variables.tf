variable "region" {
  description = "Region "
  type        = string
}

variable "project_id" {
  description = "Project ID "
  type        = string
}

variable "cluster-name" {
  description = "Name of the cluster"
  type        = string
}

variable "ssh_public_key" {
  description = "The SSH public key for accessing the bastion host."
  type        = string
}

variable "name" {
  description = "Name of the Bastion "
  type        = string
}

variable "machine_type" {
  description = "Machine type of the Instance "
  type        = string
}

variable "os" {
  description = "OS of the instance "
  type        = string
}
variable "public_subnet_id" {
  description = "The subnet ID for the public network interface"
  type        = string
}


