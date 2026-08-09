# Lab 12 — two databases on one logical server, with a connection-string output.
terraform {
  required_version = ">= 1.5.0"
  required_providers { azurerm = { source = "hashicorp/azurerm", version = "~> 3.70" } }
}
provider "azurerm" { features {} }

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

# Two databases SHARING the same server (and admin).
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

output "server_fqdn" { value = azurerm_mssql_server.this.fully_qualified_domain_name }
# A full ADO connection string you'd hand to an app. Sensitive so it's masked.
output "app_conn_string" {
  value     = "Server=tcp:${azurerm_mssql_server.this.fully_qualified_domain_name},1433;Database=sqldb-app;User Id=sqladmin;Password=${var.sql_admin_password};"
  sensitive = true
}
