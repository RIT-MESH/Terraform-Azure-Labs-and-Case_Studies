terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = { source = "hashicorp/azurerm", version = "~> 3.70" }
  }
}
provider "azurerm" { features {} }

resource "azurerm_resource_group" "this" {
  name     = "rg-diag-settings"
  location = "eastus"
}

resource "azurerm_log_analytics_workspace" "this" {
  name                = "log-diag-${substr(md5(timestamp()), 0, 8)}"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_storage_account" "logs" {
  name                     = lower("stdiag${substr(md5(timestamp()), 0, 6)}")
  resource_group_name      = azurerm_resource_group.this.name
  location                 = azurerm_resource_group.this.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "archive" {
  name                  = "diag-archive"
  storage_account_name  = azurerm_storage_account.logs.name
  container_access_type = "private"
}

# The storage account whose activity we want to capture.
resource "azurerm_storage_account" "app" {
  name                     = lower("stdiagapp${substr(md5(timestamp()), 0, 5)}")
  resource_group_name      = azurerm_resource_group.this.name
  location                 = azurerm_resource_group.this.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_blob_service_properties" "this" {
  storage_account_id = azurerm_storage_account.app.id
  logging {
    delete                = true
    read                  = true
    write                 = true
    version               = true
    retention_policy_days = 7
  }
}

# Stream storage logs/metrics to Log Analytics AND to a storage container.
resource "azurerm_monitor_diagnostic_setting" "to_la" {
  name                       = "diag-to-loganalytics"
  target_resource_id         = azurerm_storage_account.app.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.this.id

  enabled_log {
    category = "StorageRead"
  }
  enabled_log {
    category = "StorageWrite"
  }
  metric {
    category = "Transaction"
    enabled  = true
  }
}

output "workspace_id"   { value = azurerm_log_analytics_workspace.this.id }
output "app_storage"    { value = azurerm_storage_account.app.name }
