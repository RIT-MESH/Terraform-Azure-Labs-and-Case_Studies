variable "sql_admin_password" { type = string, sensitive = true }

resource "azurerm_resource_group" "this" {
  name     = "rg-sql-two"
  location = "eastus"
}

resource "azurerm_mssql_server" "this" {
  name                         = "sqlserver-two-${substr(md5(timestamp()), 0, 8)}"
  resource_group_name          = azurerm_resource_group.this.name
  location                     = azurerm_resource_group.this.location
  version                      = "12.0"
  administrator_login          = "sqladmin"
  administrator_login_password = var.sql_admin_password
}

# Two databases share one server.
resource "azurerm_mssql_database" "app" {
  name      = "sqldb-app"
  server_id = azurerm_mssql_server.this.id
  sku_name  = "Basic"
}

resource "azurerm_mssql_database" "reports" {
  name      = "sqldb-reports"
  server_id = azurerm_mssql_server.this.id
  sku_name  = "Basic"
}

output "server_fqdn"     { value = azurerm_mssql_server.this.fully_qualified_domain_name }
output "app_conn_string" {
  value     = "Server=tcp:${azurerm_mssql_server.this.fully_qualified_domain_name},1433;Database=sqldb-app;User Id=sqladmin;Password=${var.sql_admin_password};"
  sensitive = true
}
