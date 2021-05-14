locals {
  slug = {
    storage = "storage"
  }

  host_base = var.environment == "prod" ? var.domain : join(".", [var.environment, var.domain])

  host = {
    storage = lower(join(".", [local.slug.storage, local.host_base]))
  }
}

variable "domain" {
  default = "acme.com"
}

variable "environment" {
  default = "stage"
}

variable "project_id" {
  type        = string
  default     = "tip1-123456"
  description = "The project ID to host the cluster in"
}

variable "region" {
  type        = string
  default     = "europe-west3"
  description = "The region to host the cluster in"
}

variable "zone_default" {
  type        = string
  default     = "europe-west3-a"
  description = "The default zones to host the cluster in"
}

variable "zones" {
  default = [
    "europe-west3-a",
  ]
}

variable "vm_type" {
  type = string
}

variable "vm_count" {
  type = number
}

variable "vm_disk_type" {
  type = string
}

variable "vm_disk_size" {
  type = number
}

variable "storage_size" {
  default = 1
}
