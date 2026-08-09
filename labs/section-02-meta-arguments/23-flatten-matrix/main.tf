terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = { source = "hashicorp/azurerm", version = "~> 3.70" }
  }
}
provider "azurerm" { features {} }

locals {
  rg = "rg-flatten"
  region_cidr = {
    regionA = "172.20.0.0/20"
    regionB = "172.21.0.0/20"
  }
  # Nested: for each region, a list of {region, tier, cidr}. flatten() removes the nesting.
  nested = [
    for r in var.regions : [
      for i, t in var.tiers : {
        region = r
        tier   = t
        cidr   = cidrsubnet(local.region_cidr[r], 6, i)   # /26 each
      }
    ]
  ]
  flat = flatten(local.nested)
}

resource "azurerm_resource_group" "this" {
  name     = local.rg
  location = "eastus"
}

# One VNet per region.
resource "azurerm_virtual_network" "this" {
  for_each            = toset(var.regions)
  name                = "vnet-${each.key}"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  address_space       = [local.region_cidr[each.key]]
}

# One subnet per (region, tier) pair, from the flattened list.
resource "azurerm_subnet" "this" {
  for_each             = { for s in local.flat : "${s.region}-${s.tier}" => s }
  name                 = "snet-${each.value.tier}"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this[each.value.region].name
  address_prefixes     = [each.value.cidr]
}

output "subnet_keys" { value = keys(azurerm_subnet.this) }
