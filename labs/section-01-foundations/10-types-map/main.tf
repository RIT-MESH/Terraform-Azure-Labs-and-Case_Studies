locals {
  region = "eastus"
  rg     = "rg-map-foundation"

  # A map keyed by role, each value is an object describing the subnet.
  subnets = {
    web  = { prefix = "10.60.1.0/24", nsg = true }
    app  = { prefix = "10.60.2.0/24", nsg = true }
    data = { prefix = "10.60.3.0/24", nsg = false }
  }
}

resource "azurerm_resource_group" "this" {
  name     = local.rg
  location = local.region
}

resource "azurerm_virtual_network" "this" {
  name                = "vnet-map"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  address_space       = ["10.60.0.0/16"]
}

resource "azurerm_subnet" "this" {
  for_each = local.subnets

  name                 = "snet-${each.key}"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [each.value.prefix]
}

output "subnet_ids" {
  value = { for k, s in azurerm_subnet.this : k => s.id }
}
