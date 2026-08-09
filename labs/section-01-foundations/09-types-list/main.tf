locals {
  region = "eastus"
  rg     = "rg-list-foundation"
  # A LIST (ordered, index-addressed). Here a list of CIDR prefixes.
  subnet_prefixes = ["10.50.1.0/24", "10.50.2.0/24", "10.50.3.0/24"]

  # A `for` expression turns the list of strings into a LIST OF OBJECTS, adding a
  # computed name. `i` is the index, `p` the value. This is the core of repetition.
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

  # `dynamic` generates a nested `subnet {}` block for each entry. We convert the
  # list to a map (keyed by name) so `for_each` can iterate it.
  dynamic "subnet" {
    for_each = { for s in local.subnets : s.name => s }
    content {
      name           = subnet.value.name
      address_prefix = subnet.value.prefix
    }
  }
}

# `for` can also project a list into another list for outputs.
output "subnet_names" {
  value = [for s in local.subnets : s.name]
}
