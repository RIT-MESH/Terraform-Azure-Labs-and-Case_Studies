locals {
  region = "eastus"
  rg     = "rg-nic-foundation"
}

resource "azurerm_resource_group" "this" {
  name     = local.rg
  location = local.region
}

resource "azurerm_virtual_network" "this" {
  name                = "vnet-nic"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  address_space       = ["10.90.0.0/16"]
}

resource "azurerm_subnet" "web" {
  name                 = "snet-web"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = ["10.90.1.0/24"]
}

resource "azurerm_network_interface" "web" {
  name                = "nic-web-01"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name

  ip_configuration {
    name                          = "ipconfig-web"
    subnet_id                     = azurerm_subnet.web.id
    private_ip_address_allocation = "Dynamic"
  }
}

output "nic_id"          { value = azurerm_network_interface.web.id }
output "nic_private_ip"  { value = azurerm_network_interface.web.private_ip_address }
