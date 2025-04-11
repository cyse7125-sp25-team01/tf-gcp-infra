# GCP Infrastructure Setup using Terraform
# https://github.com/antonputra/tutorials/blob/main/lessons/132/k8s/prometheus-ui/1-deployment.yaml
## Overview

This repository manages the infrastructure setup for multiple GCP projects using Terraform. The structure follows a modular approach, with reusable Terraform modules stored under the `modules` directory. The infrastructure is provisioned for development (`gcp-project-dev`), production (`gcp-project-prd`), and DNS (`gcp-project-dns`) projects.

## Infrastructure Components

- **VPC**: Defines network configurations for `gcp-project-dev` and `gcp-project-prd`.
- **Bastion Host**: Provides a secure entry point to private resources.
- **GKE (Google Kubernetes Engine)**: Deploys Kubernetes clusters for application workloads in development and production environments.
- **DNS**: Configures domain name resolution for both `gcp-project-dev` and `gcp-project-prd` via `gcp-project-dns`.

## Deployment Instructions

1. **Initialize Terraform** (Run this inside each project folder):

   ```sh
   terraform init -backend-config=backend.tfavrs

   ```

2. **Plan Terraform** :

   ```sh
   terraform plan

   ```

3. **Apply Terraform** :
   ```sh
   terraform apply -auto-approve
   ```
