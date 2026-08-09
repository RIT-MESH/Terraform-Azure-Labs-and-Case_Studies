terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = { source = "hashicorp/azurerm", version = "~> 3.70" }
  }
}
provider "azurerm" { features {} }

# A token Azure uses to read the repo. For public repos a placeholder is accepted.

resource "azurerm_resource_group" "this" {
  name     = "rg-appsourcecontrol"
  location = "eastus"
}

resource "azurerm_service_plan" "this" {
  name                = "asp-appsourcecontrol"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  os_type             = "Linux"
  sku_name            = "B1"
}

resource "azurerm_linux_web_app" "this" {
  name                = "app-sourcecontrol-${substr(md5(timestamp()), 0, 8)}"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  service_plan_id     = azurerm_service_plan.this.id
  site_config {
    application_stack { node_version = "18-lts" }
  }
}

resource "azurerm_linux_web_app_source_control" "this" {
  app_id                 = azurerm_linux_web_app.this.id
  repo_url               = var.repo_url
  branch                 = var.branch
  use_manual_integration = false
  use_local_git          = false
  credential {
    username = "deploy"
    password = var.deploy_token
  }
}

output "hostname" { value = azurerm_linux_web_app.this.default_hostname }
