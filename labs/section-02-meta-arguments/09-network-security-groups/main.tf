# Lab 09 — per-tier NSG + association.
# One NSG per tier (with a tier-specific allowed port), associated to its subnet.
terraform {
  required_version = ">= 1.5.0"
  required_providers { azurerm = { source = "hashicorp/azurerm", version = "~> 3.70" } }
}
provider "azurerm" { features {} }

locals {
  # Map of tier → {prefix, port}. The port becomes the allowed inbound port.
  tiers = {
    web = { prefix = "10.180.1.0/24", port = 443 }
    app = { prefix = "10.180.2.0/24", port = 8080 }
  }
}

resource "azurerm_resource_group" "this" {
  name     = "rg-nsgs-meta"
  location = "eastus"
}

resource "azurerm_virtual_network" "this" {
  name                = "vnet-nsgs"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  address_space       = ["10.180.0.0/16"]
}

resource "azurerm_subnet" "this" {
  for_each             = local.tiers
  name                 = "snet-${each.key}"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [each.value.prefix]
}

# One NSG per tier. tostring() converts the number port to a string for the rule.
resource "azurerm_network_security_group" "this" {
  for_each            = local.tiers
  name                = "nsg-${each.key}"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name

  security_rule {
    name                       = "Allow-app"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = tostring(each.value.port)
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Associate each NSG with its matching subnet. Both maps share the same keys.
resource "azurerm_subnet_network_security_group_association" "this" {
  for_each                = local.tiers
  subnet_id               = azurerm_subnet.this[each.key].id
  network_security_group_id = azurerm_network_security_group.this[each.key].id
}
