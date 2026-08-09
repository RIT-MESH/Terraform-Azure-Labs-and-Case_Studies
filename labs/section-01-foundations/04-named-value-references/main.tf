terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = { source = "hashicorp/azurerm", version = "~> 3.70" }
  }
}
provider "azurerm" { features {} }

locals {
  rg_name = "rg-refs-foundation"
}

variable "location" {
  type    = string
  default = "eastus"
}

resource "azurerm_resource_group" "core" {
  name     = local.rg_name        # local reference
  location = var.location        # variable reference
}

resource "azurerm_storage_account" "logs" {
  name                     = lower("stlogs${substr(md5(azurerm_resource_group.core.id), 0, 6)}")
  resource_group_name      = azurerm_resource_group.core.name       # resource reference
  location                 = azurerm_resource_group.core.location   # resource reference
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

output "rg_name"    { value = azurerm_resource_group.core.name }
output "st_name"     { value = azurerm_storage_account.logs.name }
