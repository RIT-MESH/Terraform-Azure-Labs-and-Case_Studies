locals {
  ip_count = 3
}

resource "azurerm_resource_group" "this" {
  name     = "rg-multi-pips"
  location = "eastus"
}

resource "azurerm_public_ip" "this" {
  count               = local.ip_count
  name                = format("pip-%02d", count.index + 1)
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  allocation_method   = "Static"
  sku                = "Standard"
}

output "ips" { value = azurerm_public_ip.this[*].ip_address }
