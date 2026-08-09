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

# Subnet delegated to App Service for regional VNet integration.
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

resource "azurerm_service_plan" "this" {
  name                = "asp-vnet"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  os_type             = "Linux"
  sku_name            = "S1" # VNet integration needs Standard or higher
}

resource "azurerm_linux_web_app" "this" {
  name                = "app-vnet-${substr(md5(timestamp()), 0, 8)}"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  service_plan_id     = azurerm_service_plan.this.id

  virtual_network_subnet_id = azurerm_subnet.webapp.id
  vnet_route_all_enabled    = true

  site_config {
    application_stack { node_version = "18-lts" }
  }
}

output "webapp_hostname" { value = azurerm_linux_web_app.this.default_hostname }
