terraform {
  backend "remote" {
    organization = "acme"

    workspaces {
      name = "stage"
    }
  }
}

module "infra" {
  source = "../../infra"

  vm_type  = "n1-standard-2"
  vm_count = 4

  vm_disk_type = "pd-standard"
  vm_disk_size = 30
}
