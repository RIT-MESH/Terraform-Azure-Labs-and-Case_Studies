variable "subnets" {
  type = map(object({
    prefix = string
    nsg    = bool
  }))
}

resource "azurerm_resource_group" "this" {
  name     = "rg-foreach-vars"
  location = "eastus"
}

resource "azurerm_virtual_network" "this" {
  name                = "vnet-foreach-vars"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  address_space       = ["10.170.0.0/16"]
}

resource "azurerm_subnet" "this" {
  for_each             = var.subnets
  name                 = "snet-${each.key}"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [each.value.prefix]
}

resource "azurerm_network_security_group" "this" {
  for_each = { for k, v in var.subnets : k => v if v.nsg }
  name                = "nsg-${each.key}"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
}
