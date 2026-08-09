# Lab 01 — The `count` meta-argument.
# `count` creates N copies of a resource. Each copy is addressed as resource.name[0],
# resource.name[1], ... Use count when the copies are identical and index-addressed.
terraform {
  required_version = ">= 1.5.0"
  required_providers { azurerm = { source = "hashicorp/azurerm", version = "~> 3.70" } }
}
provider "azurerm" { features {} }

locals {
  rg = "rg-count-meta"
  st = lower("stcount${substr(md5(timestamp()), 0, 6)}")
}

resource "azurerm_resource_group" "this" {
  name     = local.rg
  location = "eastus"
}

resource "azurerm_storage_account" "this" {
  name                     = local.st
  resource_group_name      = azurerm_resource_group.this.name
  location                 = azurerm_resource_group.this.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# count = 3 → Terraform creates 3 containers: data-0, data-1, data-2.
# count.index is the current iteration index (0-based).
resource "azurerm_storage_container" "data" {
  count                 = 3
  name                  = "data-${count.index}"   # data-0, data-1, data-2
  storage_account_name  = azurerm_storage_account.this.name
  container_access_type = "private"
}

# When a resource uses count, you reference it as a LIST: resource.name[*].name
output "container_names" {
  value = azurerm_storage_container.data[*].name
}
