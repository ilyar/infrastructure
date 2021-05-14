output "ip" {
  value = google_compute_address.ingress.address
}

output "environment" {
  value = var.environment
}

output "zone_default" {
  value = var.zone_default
}

output "project_id" {
  value = var.project_id
}

output "service_account" {
  value = google_service_account.node_pools.email
}

output "service_account_private_key" {
  value = trim(jsonencode(jsondecode(base64decode(google_service_account_key.node_pools.private_key))["private_key"]), "\"")
}
