locals {
  st = lower("stapplogs${substr(md5(timestamp()), 0, 5)}")
}

resource "azurerm_resource_group" "this" {
  name     = "rg-applogs"
  location = "eastus"
}

resource "azurerm_storage_account" "logs" {
  name                     = local.st
  resource_group_name      = azurerm_resource_group.this.name
  location                 = azurerm_resource_group.this.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_service_plan" "this" {
  name                = "asp-applogs"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  os_type             = "Linux"
  sku_name            = "B1"
}

resource "azurerm_linux_web_app" "this" {
  name                = "app-applogs-${substr(md5(timestamp()), 0, 8)}"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  service_plan_id     = azurerm_service_plan.this.id

  site_config {
    application_stack { node_version = "18-lts" }
  }

  logs {
    http_logs {
      azure_blob_storage {
        sas_url         = azurerm_storage_account.logs.primary_blob_connection_string
        retention_in_days = 7
      }
      file_system { retention_in_days = 1 }
    }
    application_logs {
      file_system { level = "Information" }
    }
  }
}

output "default_hostname" { value = azurerm_linux_web_app.this.default_hostname }
