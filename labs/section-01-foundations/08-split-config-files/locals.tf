# locals.tf — derived values kept separate from the resources.
# Terraform merges ALL *.tf files in a folder, so splitting by concern is fine.
locals {
  region  = "eastus"
  project = "split"
  rg_name = "rg-${local.project}-${local.region}"
  common_tags = {
    project   = local.project
    managedby = "terraform"
  }
}
