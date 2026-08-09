locals {
  region  = "eastus"
  project = "split"
  rg_name = "rg-${local.project}-${local.region}"
  common_tags = {
    project   = local.project
    managedby = "terraform"
  }
}
