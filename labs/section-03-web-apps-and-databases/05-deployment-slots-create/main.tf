# Lab 05 — Deployment slots (create).
# Slots let you stage a build and warm it before swapping into production. This
# lab creates a web app PLUS a "staging" slot. Slots need a Basic+ plan.
terraform {
  required_version = ">= 1.5.0"
  required_providers { azurerm = { source = "hashicorp/azurerm", version = "~> 3.70" } }
}
provider "azurerm" { features {} }

resource "azurerm_resource_group" "this" {
  name     = "rg-slots"
  location = "eastus"
}

resource "azurerm_service_plan" "this" {
  name                = "asp-slots"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  os_type             = "Linux"
  sku_name            = "B1"
}

resource "azurerm_linux_web_app" "this" {
  name                = "app-slots-${substr(md5(timestamp()), 0, 8)}"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  service_plan_id     = azurerm_service_plan.this.id
  site_config {
    application_stack { node_version = "18-lts" }
  }
}

# A staging slot of the web app above. It shares the plan and has its own hostname.
resource "azurerm_linux_web_app_slot" "staging" {
  name           = "staging"
  app_id         = azurerm_linux_web_app.this.id
  app_service_id = azurerm_linux_web_app.this.id
  location       = azurerm_resource_group.this.location
  site_config {
    application_stack { node_version = "18-lts" }
  }
}

output "prod_hostname"    { value = azurerm_linux_web_app.this.default_hostname }
output "staging_hostname"  { value = azurerm_linux_web_app_slot.staging.default_hostname }
