resource "azurerm_resource_group" "sec" {
  name     = "rg-lz-sec"
  location = "eastus"
}

resource "azurerm_log_analytics_workspace" "this" {
  name                = "log-lz-${substr(md5(timestamp()), 0, 8)}"
  location            = azurerm_resource_group.sec.location
  resource_group_name = azurerm_resource_group.sec.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_storage_account" "logs" {
  name                     = lower("stlzlogs${substr(md5(timestamp()), 0, 5)}")
  resource_group_name      = azurerm_resource_group.sec.name
  location                 = azurerm_resource_group.sec.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"
}

output "workspace_id" { value = azurerm_log_analytics_workspace.this.id }
output "logs_sa"     { value = azurerm_storage_account.logs.name }
