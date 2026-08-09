# Lab 10 base — creates a storage account and outputs its name (to be read by consumer/).

terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = { source = "hashicorp/azurerm", version = "~> 3.70" }
  }
}
provider "azurerm" { features {} }

resource "azurerm_resource_group" "this" {
  name     = "rg-remote-base"
  location = "eastus"
}

resource "azurerm_storage_account" "this" {
  name                     = lower("stremote${substr(md5(timestamp()), 0, 6)}")
  resource_group_name      = azurerm_resource_group.this.name
  location                 = azurerm_resource_group.this.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

output "storage_account_name" { value = azurerm_storage_account.this.name }
output "resource_group_name"  { value = azurerm_resource_group.this.name }
