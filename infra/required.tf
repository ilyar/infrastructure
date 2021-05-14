terraform {
  required_version = "~> 0.14.2"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 3.50.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 1.3.2"
    }
    k8s = {
      source  = "banzaicloud/k8s"
      version = ">= 0.8.4"
    }
  }
}

data "google_client_config" "default" {
}

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone_default
}

provider "k8s" {
  host                   = module.gke.endpoint
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.gke.ca_certificate)

  load_config_file = false
}

provider "helm" {
  kubernetes {
    host                   = module.gke.endpoint
    token                  = data.google_client_config.default.access_token
    cluster_ca_certificate = base64decode(module.gke.ca_certificate)

    load_config_file = false
  }
}
