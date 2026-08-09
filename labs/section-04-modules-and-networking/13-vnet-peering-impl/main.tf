# Lab 13 — bidirectional VNet peering.
# Peering is NOT one resource — you need BOTH directions:
#  - hub → spoke (allow_forwarded_traffic lets the hub route for the spoke).
#  - spoke → hub.
# After both exist, the VNets talk to each other by private IP. Both VNets are
# in the SAME resource group here for simplicity (peering works cross-RG too).
resource "azurerm_resource_group" "this" {
  name     = "rg-peer-impl"
  location = "eastus"
}

resource "azurerm_virtual_network" "hub" {
  name                = "vnet-impl-hub"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  address_space       = ["10.24.0.0/16"]
}

resource "azurerm_virtual_network" "spoke" {
  name                = "vnet-impl-spoke"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  address_space       = ["10.25.0.0/16"]
}

resource "azurerm_virtual_network_peering" "hub_to_spoke" {
  name                      = "hub-to-spoke"
  resource_group_name       = azurerm_resource_group.this.name
  virtual_network_name      = azurerm_virtual_network.hub.name
  remote_virtual_network_id = azurerm_virtual_network.spoke.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}

resource "azurerm_virtual_network_peering" "spoke_to_hub" {
  name                      = "spoke-to-hub"
  resource_group_name       = azurerm_resource_group.this.name
  virtual_network_name      = azurerm_virtual_network.spoke.name
  remote_virtual_network_id = azurerm_virtual_network.hub.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}

output "hub_id"   { value = azurerm_virtual_network.hub.id }
output "spoke_id" { value = azurerm_virtual_network.spoke.id }
