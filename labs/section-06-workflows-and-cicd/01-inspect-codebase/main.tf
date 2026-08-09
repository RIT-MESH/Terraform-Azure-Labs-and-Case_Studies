terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = { source = "hashicorp/azurerm", version = "~> 3.70" }
  }
}
provider "azurerm" { features {} }

locals {
  region  = "eastus"
  rg_name = "rg-inspect"
  st_name = lower("stinspect${substr(md5(timestamp()), 0, 5)}")
}

resource "azurerm_resource_group" "this" {
  name     = local.rg_name
  location = local.region
}

resource "azurerm_storage_account" "this" {
  name                     = local.st_name
  resource_group_name      = azurerm_resource_group.this.name
  location                 = azurerm_resource_group.this.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

output "storage_name" { value = azurerm_storage_account.this.name }
