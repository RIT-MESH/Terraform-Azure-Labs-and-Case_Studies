terraform {
  required_version = ">= 1.5.0"
  required_providers { azurerm = { source = "hashicorp/azurerm", version = "~> 3.70" } }
}
provider "azurerm" { features {} }

locals {
  rg_name = "rg-depends-foundation"
  st_name = lower("stdep${substr(md5(timestamp()), 0, 6)}")
}

resource "azurerm_resource_group" "this" {
  name     = local.rg_name
  location = "eastus"
}

resource "azurerm_storage_account" "this" {
  name                     = local.st_name
  resource_group_name      = azurerm_resource_group.this.name
  location                 = azurerm_resource_group.this.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# The container below only references the storage account's NAME as a plain string,
# so Terraform does NOT automatically know the account must exist first.
# `depends_on` makes the order explicit (use sparingly — prefer a real reference).
resource "azurerm_storage_container" "data" {
  name                  = "data"
  storage_account_name  = local.st_name
  container_access_type = "private"

  depends_on = [azurerm_storage_account.this]
}
