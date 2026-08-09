# Lab 14 — Data sources.
# A `data` block READS an existing resource instead of creating one. Useful when
# something is managed elsewhere but you need its attributes here.
terraform {
  required_version = ">= 1.5.0"
  required_providers { azurerm = { source = "hashicorp/azurerm", version = "~> 3.70" } }
}
provider "azurerm" { features {} }

# Point this at a resource group that ALREADY exists in your subscription
# (e.g. create one with: az group create -n rg-already-here -l eastus).
variable "existing_rg_name" {
  type    = string
  default = "rg-already-here"
}

# Read (do not own) the existing resource group.
data "azurerm_resource_group" "existing" {
  name = var.existing_rg_name
}

# Create a storage account IN that existing RG, reusing its name/location.
resource "azurerm_storage_account" "this" {
  name                     = lower("stdata${substr(md5(timestamp()), 0, 6)}")
  resource_group_name      = data.azurerm_resource_group.existing.name
  location                 = data.azurerm_resource_group.existing.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

output "rg_location" { value = data.azurerm_resource_group.existing.location }
output "rg_tags"     { value = data.azurerm_resource_group.existing.tags }
