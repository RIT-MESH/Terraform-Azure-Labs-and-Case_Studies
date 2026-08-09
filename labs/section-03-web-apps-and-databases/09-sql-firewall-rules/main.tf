variable "sql_admin_password" { type = string, sensitive = true }
variable "client_ip" { type = string }

resource "azurerm_resource_group" "this" {
  name     = "rg-sql-fw"
  location = "eastus"
}

resource "azurerm_mssql_server" "this" {
  name                         = "sqlserver-fw-${substr(md5(timestamp()), 0, 8)}"
  resource_group_name          = azurerm_resource_group.this.name
  location                     = azurerm_resource_group.this.location
  version                      = "12.0"
  administrator_login          = "sqladmin"
  administrator_login_password = var.sql_admin_password
  minimum_tls_version          = "1.2"
}

resource "azurerm_mssql_firewall_rule" "client" {
  name             = "AllowClient"
  server_id        = azurerm_mssql_server.this.id
  start_ip_address = var.client_ip
  end_ip_address   = var.client_ip
}

resource "azurerm_mssql_firewall_rule" "azure" {
  name             = "AllowAzureServices"
  server_id        = azurerm_mssql_server.this.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

output "server_fqdn" { value = azurerm_mssql_server.this.fully_qualified_domain_name }
