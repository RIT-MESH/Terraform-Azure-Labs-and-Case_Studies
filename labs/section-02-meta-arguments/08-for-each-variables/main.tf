# Lab 08 — for_each with a typed map variable + a FILTERED for_each.
# Shows: typed map(object) variable, and using a `for` filter to create NSGs only
# for the tiers where nsg=true.
terraform {
  required_version = ">= 1.5.0"
  required_providers { azurerm = { source = "hashicorp/azurerm", version = "~> 3.70" } }
}
provider "azurerm" { features {} }

# A map(object({...})) variable — each value is an object with prefix + nsg.
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

# for_each over the variable directly: one subnet per key.
resource "azurerm_subnet" "this" {
  for_each             = var.subnets
  name                 = "snet-${each.key}"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [each.value.prefix]
}

# FILTERED for_each: the `for` keeps only entries where v.nsg is true.
# So the "data" tier (nsg=false) gets no NSG.
resource "azurerm_network_security_group" "this" {
  for_each = { for k, v in var.subnets : k => v if v.nsg }
  name                = "nsg-${each.key}"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
}
