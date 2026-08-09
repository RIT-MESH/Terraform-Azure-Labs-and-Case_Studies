terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = { source = "hashicorp/azurerm", version = "~> 3.70" }
  }
}
provider "azurerm" { features {} }

locals {
  rg   = "rg-cidrsubnet"
  base = "172.18.0.0/20"           # /20 = 4096 addresses
  tier = ["web", "app", "data", "mgmt"]
  # Carve 4 /26 subnets (newbits=6 → /26) from the base, one per tier.
  subnets = [
    for i, t in local.tier : {
      name   = "snet-${t}"
      cidr   = cidrsubnet(local.base, 6, i)   # /26
      first  = cidrhost(cidrsubnet(local.base, 6, i), 1)
    }
  ]
}

resource "azurerm_resource_group" "this" {
  name     = local.rg
  location = "eastus"
}

resource "azurerm_virtual_network" "this" {
  name                = "vnet-cidrsubnet"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  address_space       = [local.base]
}

resource "azurerm_subnet" "this" {
  for_each             = { for s in local.subnets : s.name => s }
  name                 = each.key
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [each.value.cidr]
}

output "subnets" {
  value = { for s in local.subnets : s.name => { cidr = s.cidr, first_host = s.first } }
}
