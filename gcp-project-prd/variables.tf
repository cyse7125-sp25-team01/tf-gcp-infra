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
