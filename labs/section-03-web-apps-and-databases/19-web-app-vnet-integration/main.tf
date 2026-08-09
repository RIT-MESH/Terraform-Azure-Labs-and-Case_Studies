# Lab 19 — App Service VNet integration.
# When a database is private (no public access), the web app must integrate with
# a VNet to reach it. We create a subnet DELEGATED to App Service and wire the
# web app to it. vnet_route_all_enabled sends ALL traffic through the VNet.
terraform {
  required_version = ">= 1.5.0"
  required_providers { azurerm = { source = "hashicorp/azurerm", version = "~> 3.70" } }
}
provider "azurerm" { features {} }

resource "azurerm_resource_group" "this" {
  name     = "rg-webapp-vnet"
  location = "eastus"
}

resource "azurerm_virtual_network" "this" {
  name                = "vnet-webapp"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  address_space       = ["10.253.0.0/16"]
}

# A subnet DELEGATED to Microsoft.Web/serverFarms (required for regional VNet integration).
resource "azurerm_subnet" "webapp" {
  name                 = "snet-webapp"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = ["10.253.1.0/26"]

  delegation {
    name = "delegation"
    service_delegation {
      name    = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

# VNet integration needs Standard+ plan (B1 is too small).
resource "azurerm_service_plan" "this" {
  name                = "asp-vnet"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  os_type             = "Linux"
  sku_name            = "S1"
}

resource "azurerm_linux_web_app" "this" {
  name                = "app-vnet-${substr(md5(timestamp()), 0, 8)}"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  service_plan_id     = azurerm_service_plan.this.id

  # Bind the app to the delegated subnet → it can now reach private resources in the VNet.
  virtual_network_subnet_id = azurerm_subnet.webapp.id
  vnet_route_all_enabled    = true

  site_config {
    application_stack { node_version = "18-lts" }
  }
}

output "webapp_hostname" { value = azurerm_linux_web_app.this.default_hostname }
