variable "postgres_password" {
  description = "Postgres password"
  type        = string
}

variable "dockerhub-secret" {
  description = "Dockerhub secret"
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

variable "secret_name" {
  description = "Secret Name"
  type        = string
}

variable "region" {
  description = "Region"
  type        = string
}
