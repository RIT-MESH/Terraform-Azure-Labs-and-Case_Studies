variable "sql_admin_password" { type = string, sensitive = true }

resource "azurerm_resource_group" "this" {
  name     = "rg-sql"
  location = "eastus"
}

resource "azurerm_mssql_server" "this" {
  name                         = "sqlserver-${substr(md5(timestamp()), 0, 8)}"
  resource_group_name          = azurerm_resource_group.this.name
  location                     = azurerm_resource_group.this.location
  version                      = "12.0"
  administrator_login          = "sqladmin"
  administrator_login_password = var.sql_admin_password
  minimum_tls_version          = "1.2"
}

resource "azurerm_mssql_database" "this" {
  name      = "sqldb-app"
  server_id = azurerm_mssql_server.this.id
  sku_name  = "Basic"     # 5 DTU, 2 GB
  max_size_gb = 2
}

output "server_fqdn"   { value = azurerm_mssql_server.this.fully_qualified_domain_name }
output "database_name" { value = azurerm_mssql_database.this.name }
