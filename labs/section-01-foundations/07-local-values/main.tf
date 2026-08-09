terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = { source = "hashicorp/azurerm", version = "~> 3.70" }
  }
}
provider "azurerm" { features {} }

locals {
  region  = "eastus"
  project = "foundation"
  rg_name = "rg-${local.project}-${local.region}"

  common_tags = {
    project   = local.project
    managedby = "terraform"
    section   = "01-foundations"
  }
}

resource "azurerm_resource_group" "this" {
  name     = local.rg_name
  location = local.region
  tags     = local.common_tags
}

resource "azurerm_virtual_network" "this" {
  name                = "vnet-${local.project}"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  address_space       = ["10.30.0.0/16"]
  tags                = merge(local.common_tags, { tier = "network" })
}

output "tags" { value = azurerm_virtual_network.this.tags }
