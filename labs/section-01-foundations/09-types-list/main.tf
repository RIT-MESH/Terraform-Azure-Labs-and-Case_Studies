locals {
  region = "eastus"
  rg     = "rg-list-foundation"
  # A list of CIDR prefixes.
  subnet_prefixes = ["10.50.1.0/24", "10.50.2.0/24", "10.50.3.0/24"]
  # Build a list of {name, prefix} objects using a for expression.
  subnets = [for i, p in local.subnet_prefixes : {
    name   = "snet-tier${i + 1}"
    prefix = p
  }]
}

resource "azurerm_resource_group" "this" {
  name     = local.rg
  location = local.region
}

resource "azurerm_virtual_network" "this" {
  name                = "vnet-list"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  address_space       = ["10.50.0.0/16"]

  dynamic "subnet" {
    for_each = { for s in local.subnets : s.name => s }
    content {
      name           = subnet.value.name
      address_prefix = subnet.value.prefix
    }
  }
}

output "subnet_names" {
  value = [for s in local.subnets : s.name]
}
