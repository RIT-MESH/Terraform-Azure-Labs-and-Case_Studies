resource "azurerm_resource_group" "this" {
  name     = "rg-fw-deploy"
  location = "eastus"
}

resource "azurerm_virtual_network" "hub" {
  name                = "vnet-hub-fw-deploy"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  address_space       = ["10.29.0.0/16"]
}

resource "azurerm_subnet" "firewall" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = ["10.29.0.0/26"]
}

resource "azurerm_public_ip" "fw" {
  name                = "pip-fw"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  allocation_method   = "Static"
  sku                = "Standard"
}

resource "azurerm_firewall" "this" {
  name                = "azfw"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  sku_name            = "AZFW_VNet"
  sku_tier            = "Standard"

  ip_configuration {
    name                 = "ipconfig"
    subnet_id            = azurerm_subnet.firewall.id
    public_ip_address_id = azurerm_public_ip.fw.id
  }
}

output "firewall_private_ip" { value = azurerm_firewall.this.ip_configuration[0].private_ip_address }
output "firewall_id"         { value = azurerm_firewall.this.id }
