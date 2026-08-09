# Lab 07 — Landing Zone: hub + two spoke VNets and hub→spoke peering.
#  - vnet-lz-hub, vnet-lz-data, vnet-lz-sec.
#  - peering from hub to each spoke (allow_forwarded_traffic so the hub can route).
# (Full bidirectional peering would add spoke→hub rules too; this lab keeps it simple.)
resource "azurerm_resource_group" "net" {
  name     = "rg-lz-net"
  location = "eastus"
}

resource "azurerm_virtual_network" "hub" {
  name                = "vnet-lz-hub"
  location            = azurerm_resource_group.net.location
  resource_group_name = azurerm_resource_group.net.name
  address_space       = ["10.40.0.0/16"]
}

resource "azurerm_virtual_network" "spoke_data" {
  name                = "vnet-lz-data"
  location            = azurerm_resource_group.net.location
  resource_group_name = azurerm_resource_group.net.name
  address_space       = ["10.41.0.0/16"]
}

resource "azurerm_virtual_network" "spoke_sec" {
  name                = "vnet-lz-sec"
  location            = azurerm_resource_group.net.location
  resource_group_name = azurerm_resource_group.net.name
  address_space       = ["10.42.0.0/16"]
}

resource "azurerm_virtual_network_peering" "hub_data" {
  name                      = "hub-to-data"
  resource_group_name       = azurerm_resource_group.net.name
  virtual_network_name      = azurerm_virtual_network.hub.name
  remote_virtual_network_id = azurerm_virtual_network.spoke_data.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}

resource "azurerm_virtual_network_peering" "hub_sec" {
  name                      = "hub-to-sec"
  resource_group_name       = azurerm_resource_group.net.name
  virtual_network_name      = azurerm_virtual_network.hub.name
  remote_virtual_network_id = azurerm_virtual_network.spoke_sec.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}

output "hub_id"     { value = azurerm_virtual_network.hub.id }
output "spoke_data" { value = azurerm_virtual_network.spoke_data.id }
output "spoke_sec"  { value = azurerm_virtual_network.spoke_sec.id }
