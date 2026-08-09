# Lab 11 — VNet peering setup (two VNets, one per region, no peering yet).
#  - rg-hub (eastus) with vnet-hub (10.20.0.0/16) + snet-hub.
#  - rg-spoke (westus2) with vnet-spoke (10.21.0.0/16) + snet-spoke.
# Lab 13 will peer them (peering must reference both VNets).
resource "azurerm_resource_group" "hub" {
  name     = "rg-hub"
  location = "eastus"
}
resource "azurerm_resource_group" "spoke" {
  name     = "rg-spoke"
  location = "westus2"
}

resource "azurerm_virtual_network" "hub" {
  name                = "vnet-hub"
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name
  address_space       = ["10.20.0.0/16"]
}

resource "azurerm_subnet" "hub" {
  name                 = "snet-hub"
  resource_group_name  = azurerm_resource_group.hub.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = ["10.20.1.0/24"]
}

resource "azurerm_virtual_network" "spoke" {
  name                = "vnet-spoke"
  location            = azurerm_resource_group.spoke.location
  resource_group_name = azurerm_resource_group.spoke.name
  address_space       = ["10.21.0.0/16"]
}

resource "azurerm_subnet" "spoke" {
  name                 = "snet-spoke"
  resource_group_name  = azurerm_resource_group.spoke.name
  virtual_network_name = azurerm_virtual_network.spoke.name
  address_prefixes     = ["10.21.1.0/24"]
}

output "hub_id"   { value = azurerm_virtual_network.hub.id }
output "spoke_id" { value = azurerm_virtual_network.spoke.id }
