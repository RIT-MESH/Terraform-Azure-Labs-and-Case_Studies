locals {
  tiers = toset(["web", "app", "data"])
}

resource "azurerm_resource_group" "this" {
  name     = "rg-multi-nics"
  location = "eastus"
}

resource "azurerm_virtual_network" "this" {
  name                = "vnet-multi-nics"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  address_space       = ["10.160.0.0/16"]
}

resource "azurerm_subnet" "this" {
  for_each             = { for i, t in local.tiers : t => "10.160.${i + 1}.0/24" }
  name                 = "snet-${each.key}"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [each.value]
}

resource "azurerm_network_interface" "this" {
  for_each            = azurerm_subnet.this
  name                = "nic-${each.key}"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  ip_configuration {
    name                          = "ipconfig"
    subnet_id                     = each.value.id
    private_ip_address_allocation = "Dynamic"
  }
}

output "nics" { value = keys(azurerm_network_interface.this) }
