// terraform import module.infra.google_compute_address.ingress  projects/acme-288414/regions/europe-west3/addresses/stage-ingress
resource "google_compute_address" "ingress" {
  name   = "${var.environment}-ingress"
  region = var.region
}

// terraform import module.infra.google_service_account.service_account projects/acme-123456/serviceAccounts/stage-cluster@acme-123456.iam.gserviceaccount.com
resource "google_service_account" "node_pools" {
  account_id   = "${var.environment}-node-cluster"
  display_name = "${var.environment}-node-cluster"
  description  = "for ${var.environment} node cluster"
}

resource "google_service_account_key" "node_pools" {
  service_account_id = google_service_account.node_pools.name
}

// network with private secondary ip ranges
resource "google_compute_subnetwork" "default" {
  name    = "${var.environment}-subnetwork"
  region  = var.region
  network = "default"

  ip_cidr_range = "10.56.4.0/22"

  secondary_ip_range = [
    {
      range_name    = "${var.environment}-secondary-range-1"
      ip_cidr_range = "10.32.0.0/13"
    },
    {
      range_name    = "${var.environment}-secondary-range-2"
      ip_cidr_range = "10.30.0.0/18"
    },
  ]
}

module "gke" {
  source = "terraform-google-modules/kubernetes-engine/google"

  project_id = var.project_id
  name       = var.environment
  region     = var.region
  zones      = var.zones
  regional   = false

  network           = "default"
  subnetwork        = google_compute_subnetwork.default.name
  ip_range_pods     = google_compute_subnetwork.default.secondary_ip_range[0].range_name
  ip_range_services = google_compute_subnetwork.default.secondary_ip_range[1].range_name

  http_load_balancing        = false
  horizontal_pod_autoscaling = true
  network_policy             = true

  create_service_account = false
  monitoring_service     = "none"
  logging_service        = "none"

  node_pools = [
    {
      name = "default"

      machine_type = var.vm_type
      min_count    = 1
      max_count    = var.vm_count

      local_ssd_count = 0

      disk_size_gb = var.vm_disk_size
      disk_type    = var.vm_disk_type

      image_type   = "COS"
      auto_repair  = true
      auto_upgrade = true
      preemptible  = false

      initial_node_count = 2

      service_account = google_service_account.node_pools.email

      node_metadata = "EXPOSE"
    }
  ]

  remove_default_node_pool = true
}
