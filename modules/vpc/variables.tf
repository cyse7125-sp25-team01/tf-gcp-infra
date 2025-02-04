# variables.tf
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}
variable "region" {
  description = "Region "
  type        = string
}
variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
  default     = "app-vpc"
}

variable "destination_cidr" {
  description = "Destination CIDR block for the default route"
  type        = string
  default     = "0.0.0.0/0"
}