variable "sql_admin_password" { type = string, sensitive = true }
variable "log_workspace_id" { type = string }

resource "azurerm_resource_group" "data" {
  name     = "rg-lz-db"
  location = "eastus"
}

resource "azurerm_mssql_server" "this" {
  name                         = "sql-lz-${substr(md5(timestamp()), 0, 8)}"
  resource_group_name          = azurerm_resource_group.data.name
  location                     = azurerm_resource_group.data.location
  version                      = "12.0"
  administrator_login          = "sqladmin"
  administrator_login_password = var.sql_admin_password
  minimum_tls_version          = "1.2"
}

resource "azurerm_mssql_firewall_rule" "azure" {
  name             = "AllowAzure"
  server_id        = azurerm_mssql_server.this.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

resource "azurerm_mssql_database" "this" {
  name      = "sqldb-lz"
  server_id = azurerm_mssql_server.this.id
  sku_name  = "S0"
}

resource "azurerm_monitor_diagnostic_setting" "sql" {
  name                       = "diag-sql"
  target_resource_id         = azurerm_mssql_database.this.id
  log_analytics_workspace_id = var.log_workspace_id

  enabled_log {
    category = "SQLSecurityAuditEvents"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}

output "server_fqdn" { value = azurerm_mssql_server.this.fully_qualified_domain_name }
