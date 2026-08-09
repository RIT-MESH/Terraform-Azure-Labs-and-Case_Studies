terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = { source = "hashicorp/azurerm", version = "~> 3.70" }
  }
}
provider "azurerm" { features {} }

locals {
  rg_name  = "rg-vnet-foundation"
  region   = "eastus"
  vnet     = "vnet-foundation"
}

resource "azurerm_resource_group" "this" {
  name     = local.rg_name
  location = local.region
}

resource "azurerm_virtual_network" "this" {
  name                = local.vnet
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  address_space       = ["10.20.0.0/16"]

  subnet {
    name           = "snet-web"
    address_prefix = "10.20.1.0/24"
  }

  subnet {
    name           = "snet-app"
    address_prefix = "10.20.2.0/24"
  }
}

output "vnet_id"   { value = azurerm_virtual_network.this.id }
output "vnet_name" { value = azurerm_virtual_network.this.name }
