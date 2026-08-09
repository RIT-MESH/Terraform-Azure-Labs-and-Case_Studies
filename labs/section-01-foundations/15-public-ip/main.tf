locals {
  rg = "rg-pip-foundation"
}

resource "azurerm_resource_group" "this" {
  name     = local.rg
  location = "eastus"
}

# A Public IP makes a resource reachable from the internet.
# - allocation_method: "Static" gets a fixed IP; "Dynamic" changes on stop.
# - sku: "Basic" (legacy) or "Standard" (required for zone-redundant LBs).
resource "azurerm_public_ip" "web" {
  name                = "pip-web-01"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  allocation_method   = "Static"
  sku                = "Standard"
}

# The IP is only known AFTER creation. Read it from .ip_address in an output.
output "public_ip" { value = azurerm_public_ip.web.ip_address }
