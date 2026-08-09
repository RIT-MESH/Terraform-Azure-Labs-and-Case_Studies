variable "landing_zone_name" {
  type    = string
  default = "app1"
}

variable "location" { type = string, default = "eastus" }

locals {
  rg_names = {
    network  = "rg-${var.landing_zone_name}-net"
    data     = "rg-${var.landing_zone_name}-data"
    security = "rg-${var.landing_zone_name}-sec"
  }
  common_tags = {
    landing_zone = var.landing_zone_name
    managedby    = "terraform"
  }
}

resource "azurerm_resource_group" "network" {
  name     = local.rg_names.network
  location = var.location
  tags     = local.common_tags
}

resource "azurerm_resource_group" "data" {
  name     = local.rg_names.data
  location = var.location
  tags     = local.common_tags
}

resource "azurerm_resource_group" "security" {
  name     = local.rg_names.security
  location = var.location
  tags     = local.common_tags
}

output "rg_names" { value = local.rg_names }
