# Lab 10 — Traffic Manager with PRIORITY routing (active/passive failover).
# Same shape as lab 09 but traffic_routing_method = "Priority".
#  - Two web apps in different regions.
#  - One endpoint each, with priority 1 and 2. ALL traffic goes to priority 1;
#    if it's unhealthy, TM fails over to priority 2 automatically.
locals {
  regions = ["eastus", "westus2"]
}

resource "azurerm_resource_group" "this" {
  name     = "rg-tm-impl"
  location = local.regions[0]
}

resource "azurerm_service_plan" "this" {
  count               = 2
  name                = "asp-tmimpl-${count.index}"
  location            = local.regions[count.index]
  resource_group_name = azurerm_resource_group.this.name
  os_type             = "Linux"
  sku_name            = "B1"
}

resource "azurerm_linux_web_app" "this" {
  count               = 2
  name                = "app-tmimpl-${count.index}-${substr(md5(timestamp()), 0, 6)}"
  location            = local.regions[count.index]
  resource_group_name = azurerm_resource_group.this.name
  service_plan_id     = azurerm_service_plan.this[count.index].id
  site_config {
    application_stack { node_version = "18-lts" }
  }
}

resource "azurerm_traffic_manager_profile" "this" {
  name                    = "tmimpl-${substr(md5(timestamp()), 0, 10)}"
  resource_group_name    = azurerm_resource_group.this.name
  traffic_routing_method = "Priority"

  dns_config {
    relative_name = "tmimpl-${substr(md5(timestamp()), 0, 10)}"
    ttl           = 30
  }
  monitor_config {
    protocol = "http"
    port     = 80
    path     = "/"
  }
}

resource "azurerm_traffic_manager_endpoint" "this" {
  count               = 2
  name                = "ep-${count.index}"
  resource_group_name = azurerm_resource_group.this.name
  profile_name        = azurerm_traffic_manager_profile.this.name
  type                = "azureEndpoints"
  target_resource_id  = azurerm_linux_web_app.this[count.index].id
  endpoint_location   = local.regions[count.index]
  priority            = count.index + 1
}

output "tm_dns" { value = azurerm_traffic_manager_profile.this.dns_config[0].fqdn }
