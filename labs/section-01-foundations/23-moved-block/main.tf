terraform {
  required_version = ">= 1.5.0"
  required_providers { azurerm = { source = "hashicorp/azurerm", version = "~> 3.70" } }
}
provider "azurerm" { features {} }

locals {
  rg   = "rg-moved-block"
  vnet = "172.16.0.0/20"   # /20 = 4096 addresses (not the usual /16)
  snet = "172.16.0.0/26"   # /26 = 64 addresses (not the usual /24)
}

resource "azurerm_resource_group" "this" {
  name     = local.rg
  location = "eastus"
}

resource "azurerm_virtual_network" "this" {
  name                = "vnet-moved"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  address_space       = [local.vnet]
}

resource "azurerm_subnet" "web" {
  name                 = "snet-web"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [local.snet]
}

# The storage account at its NEW address (this).
resource "azurerm_storage_account" "this" {
  name                     = lower("stmoved${substr(md5(timestamp()), 0, 6)}")
  resource_group_name      = azurerm_resource_group.this.name
  location                 = azurerm_resource_group.this.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# `moved {}` tells Terraform: anything previously managed as .legacy is now .this.
# Terraform updates the STATE address IN PLACE — no destroy/create of the real
# resource. Remove this block after everyone has applied the rename.
moved {
  from = azurerm_storage_account.legacy
  to   = azurerm_storage_account.this
}

output "storage_name" { value = azurerm_storage_account.this.name }
