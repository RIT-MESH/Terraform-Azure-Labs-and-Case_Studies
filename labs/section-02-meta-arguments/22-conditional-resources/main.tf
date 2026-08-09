terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = { source = "hashicorp/azurerm", version = "~> 3.70" }
  }
}
provider "azurerm" { features {} }

variable "deploy_nsg" {
  type    = bool
  default = true
}

locals {
  rg   = "rg-conditional"
  vnet = "172.19.0.0/20"
  snet = "172.19.0.0/26"
}

resource "azurerm_resource_group" "this" {
  name     = local.rg
  location = "eastus"
}

resource "azurerm_virtual_network" "this" {
  name                = "vnet-conditional"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  address_space       = [local.vnet]
}

resource "azurerm_subnet" "web" {
  name                 = "snet-web"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [local.snet]
}

# The NSG only exists when the feature flag is on.
resource "azurerm_network_security_group" "web" {
  count               = var.deploy_nsg ? 1 : 0
  name                = "nsg-conditional"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
}

resource "azurerm_subnet_network_security_group_association" "web" {
  count                   = var.deploy_nsg ? 1 : 0
  subnet_id               = azurerm_subnet.web.id
  network_security_group_id = azurerm_network_security_group.web[0].id
}

output "nsg_created" { value = var.deploy_nsg }
