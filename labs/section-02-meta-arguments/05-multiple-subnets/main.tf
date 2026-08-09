# Lab 05 — Multiple subnets with for_each over a map.
# The most-reused networking pattern: one VNet, several subnets from a map.
terraform {
  required_version = ">= 1.5.0"
  required_providers { azurerm = { source = "hashicorp/azurerm", version = "~> 3.70" } }
}
provider "azurerm" { features {} }

locals {
  # Map of tier → CIDR. Each entry becomes one subnet.
  subnets = {
    web  = "10.150.1.0/24"
    app  = "10.150.2.0/24"
    data = "10.150.3.0/24"
    mgmt = "10.150.4.0/24"
  }
}

resource "azurerm_resource_group" "this" {
  name     = "rg-multi-subnets"
  location = "eastus"
}

resource "azurerm_virtual_network" "this" {
  name                = "vnet-multi-subnets"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  address_space       = ["10.150.0.0/16"]
}

# One subnet per map entry. each.key = "web", each.value = "10.150.1.0/24".
resource "azurerm_subnet" "this" {
  for_each             = local.subnets
  name                 = "snet-${each.key}"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [each.value]
}

output "subnet_ids" {
  value = { for k, s in azurerm_subnet.this : k => s.id }
}
