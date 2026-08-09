terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = { source = "hashicorp/azurerm", version = "~> 3.70" }
  }
}
provider "azurerm" { features {} }

variable "tier" {
  type    = string
  default = "Standard"
}

resource "azurerm_resource_group" "this" {
  name     = "rg-tftest"
  location = "eastus"
}

resource "azurerm_storage_account" "this" {
  name                     = lower("sttftest${substr(md5(timestamp()), 0, 6)}")
  resource_group_name      = azurerm_resource_group.this.name
  location                 = azurerm_resource_group.this.location
  account_tier             = var.tier
  account_replication_type = "LRS"
}

output "storage_name" { value = azurerm_storage_account.this.name }
