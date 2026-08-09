terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = { source = "hashicorp/azurerm", version = "~> 3.70" }
  }
}
provider "azurerm" { features {} }

resource "azurerm_resource_group" "this" {
  name     = "rg-moved-removed"
  location = "eastus"
}

# Current (new) address of the storage account.
resource "azurerm_storage_account" "this" {
  name                     = lower("stmovedrm${substr(md5(timestamp()), 0, 5)}")
  resource_group_name      = azurerm_resource_group.this.name
  location                 = azurerm_resource_group.this.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Anything previously managed as .legacy is now .this (no destroy/create).
moved {
  from = azurerm_storage_account.legacy
  to   = azurerm_storage_account.this
}

# Drop .orphan from state on the next plan/apply WITHOUT deleting the cloud resource.
removed {
  from = azurerm_storage_account.orphan
}

output "storage_name" { value = azurerm_storage_account.this.name }
