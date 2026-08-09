# Lab 07 — multiple public IPs with count + format().
terraform {
  required_version = ">= 1.5.0"
  required_providers { azurerm = { source = "hashicorp/azurerm", version = "~> 3.70" } }
}
provider "azurerm" { features {} }

locals {
  ip_count = 3
}

resource "azurerm_resource_group" "this" {
  name     = "rg-multi-pips"
  location = "eastus"
}

# format("pip-%02d", 1) → "pip-01" (zero-padded, 2 digits). %02d = at least 2 digits.
resource "azurerm_public_ip" "this" {
  count               = local.ip_count
  name                = format("pip-%02d", count.index + 1)
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  allocation_method   = "Static"
  sku                = "Standard"
}

output "ips" { value = azurerm_public_ip.this[*].ip_address }
