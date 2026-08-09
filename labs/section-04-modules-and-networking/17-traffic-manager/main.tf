locals {
  regions = ["eastus", "westeurope"]
}

resource "azurerm_resource_group" "this" {
  name     = "rg-tm"
  location = local.regions[0]
}

resource "azurerm_service_plan" "this" {
  count               = 2
  name                = "asp-tm-${count.index}"
  location            = local.regions[count.index]
  resource_group_name = azurerm_resource_group.this.name
  os_type             = "Linux"
  sku_name            = "B1"
}

resource "azurerm_linux_web_app" "this" {
  count               = 2
  name                = "app-tm-${count.index}-${substr(md5(timestamp()), 0, 6)}"
  location            = local.regions[count.index]
  resource_group_name = azurerm_resource_group.this.name
  service_plan_id     = azurerm_service_plan.this[count.index].id
  site_config {
    application_stack { node_version = "18-lts" }
  }
  tags = { region = local.regions[count.index] }
}

resource "azurerm_traffic_manager_profile" "this" {
  name                   = "tm-${substr(md5(timestamp()), 0, 10)}"
  resource_group_name    = azurerm_resource_group.this.name
  traffic_routing_method = "Performance"

  dns_config {
    relative_name = "tm-${substr(md5(timestamp()), 0, 10)}"
    ttl           = 30
  }

  monitor_config {
    protocol = "http"
    port     = 80
    path     = "/"
  }
}

resource "azurerm_traffic_manager_endpoint" "this" {
  count                 = 2
  name                  = "ep-${count.index}"
  resource_group_name   = azurerm_resource_group.this.name
  profile_name          = azurerm_traffic_manager_profile.this.name
  type                  = "azureEndpoints"
  target_resource_id    = azurerm_linux_web_app.this[count.index].id
  endpoint_location     = local.regions[count.index]
}

output "tm_dns" { value = azurerm_traffic_manager_profile.this.dns_config[0].fqdn }
