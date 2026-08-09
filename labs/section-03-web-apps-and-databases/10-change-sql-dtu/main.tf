variable "sql_admin_password" { type = string, sensitive = true }
variable "sku_name" {
  type    = string
  default = "Basic"
}

resource "azurerm_resource_group" "this" {
  name     = "rg-sql-dtu"
  location = "eastus"
}

resource "azurerm_mssql_server" "this" {
  name                         = "sqlserver-dtu-${substr(md5(timestamp()), 0, 8)}"
  resource_group_name          = azurerm_resource_group.this.name
  location                     = azurerm_resource_group.this.location
  version                      = "12.0"
  administrator_login          = "sqladmin"
  administrator_login_password = var.sql_admin_password
}

resource "azurerm_mssql_database" "this" {
  name      = "sqldb-dtu"
  server_id = azurerm_mssql_server.this.id
  sku_name  = var.sku_name
}

output "sku" { value = azurerm_mssql_database.this.sku_name }
