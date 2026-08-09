# Lab 03 — The `for_each` meta-argument.
# for_each creates one resource per element of a SET or MAP. Each copy is
# addressed by its KEY: resource.name["key"]. Prefer for_each over count when
# copies differ in config and are best addressed by a meaningful key.
terraform {
  required_version = ">= 1.5.0"
  required_providers { azurerm = { source = "hashicorp/azurerm", version = "~> 3.70" } }
}
provider "azurerm" { features {} }

locals {
  # toset() converts a list to a set (unique, unordered). for_each over a set
  # creates one resource per string: "dev", "stg", "prod".
  stages = toset(["dev", "stg", "prod"])
  st     = lower("stforeach${substr(md5(timestamp()), 0, 6)}")
}

resource "azurerm_resource_group" "this" {
  name     = "rg-foreach-meta"
  location = "eastus"
}

resource "azurerm_storage_account" "this" {
  name                     = local.st
  resource_group_name      = azurerm_resource_group.this.name
  location                 = azurerm_resource_group.this.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# for_each over the set. each.value is the string ("dev"); with a set, each.key
# and each.value are the same.
resource "azurerm_storage_container" "stage" {
  for_each              = local.stages
  name                  = each.value
  storage_account_name  = azurerm_storage_account.this.name
  container_access_type = "private"
}

# When a resource uses for_each, you reference it as a MAP: keys(resource.name)
output "containers" { value = keys(azurerm_storage_container.stage) }
