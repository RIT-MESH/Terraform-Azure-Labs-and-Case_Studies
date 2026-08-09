locals {
  rg = "rg-pip-foundation"
}

resource "azurerm_resource_group" "this" {
  name     = local.rg
  location = "eastus"
}

resource "azurerm_public_ip" "web" {
  name                = "pip-web-01"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  allocation_method   = "Static"
  sku                = "Standard"
}

output "public_ip" { value = azurerm_public_ip.web.ip_address }
