variable "region" {
  description = "Region "
  type        = string
}

variable "project_id" {
  description = "Project ID "
  type        = string
}

variable "master_cidr_block" {
  description = "CIDR block of master nodes"
  type        = string
}

variable "vpc_network" {
  description = "The name of the VPC network"
  type        = string
}

variable "private_subnet" {
  description = "The private subnet"
  type        = string
}

# variable "bastion_external_ip" {
#   description = "Bastion External IP"
# }

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet" {
  description = "The public subnet"
  type        = string
}

variable "cluster-name" {
  description = "Name of the cluster"
  type        = string
}
