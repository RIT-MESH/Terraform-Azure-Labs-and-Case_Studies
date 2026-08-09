# Lab 01 — Azure Web App (App Service).
# App Service is the managed PaaS for web apps: no VM, no OS patching, easy scale.
# We create a Service Plan (the compute) + a Linux Web App (the app).
terraform {
  required_version = ">= 1.5.0"
  required_providers { azurerm = { source = "hashicorp/azurerm", version = "~> 3.70" } }
}
provider "azurerm" { features {} }

locals { rg = "rg-webapp" }

resource "azurerm_resource_group" "this" {
  name     = local.rg
  location = "eastus"
}

# The Service Plan = the compute tier. sku_name "B1" = small shared Linux.
# os_type must match the web app (Linux here).
resource "azurerm_service_plan" "this" {
  name                = "asp-webapp"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  os_type             = "Linux"
  sku_name            = "B1"
}

# A Linux Web App runs your code. Names are globally unique (web app DNS).
resource "azurerm_linux_web_app" "this" {
  name                = "app-webapp-${substr(md5(timestamp()), 0, 8)}"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  service_plan_id     = azurerm_service_plan.this.id

  site_config {
    application_stack {
      node_version = "18-lts"   # the runtime/language stack
    }
  }
}

output "default_hostname" { value = azurerm_linux_web_app.this.default_hostname }
