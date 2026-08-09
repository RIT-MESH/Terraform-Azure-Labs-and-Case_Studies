resource "azurerm_resource_group" "this" {
  name     = "rg-loganalytics"
  location = "eastus"
}

resource "azurerm_log_analytics_workspace" "this" {
  name                = "log-${substr(md5(timestamp()), 0, 10)}"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

output "workspace_id" { value = azurerm_log_analytics_workspace.this.id }
output "customer_id" { value = azurerm_log_analytics_workspace.this.workspace_id }
