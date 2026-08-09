# Lab 09 — SQL firewall rules.
# By default NOTHING can reach a SQL logical server. We add two rules:
#   - one for your client IP (so you can connect from your machine)
#   - one for "0.0.0.0" (the special range meaning "other Azure services")
terraform {
  required_version = ">= 1.5.0"
  required_providers { azurerm = { source = "hashicorp/azurerm", version = "~> 3.70" } }
}
provider "azurerm" { features {} }

variable "sql_admin_password" { type = string, sensitive = true }
variable "client_ip"          { type = string }

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

# Allow YOUR client IP to connect (e.g. from SSMS / Azure Data Studio).
resource "azurerm_mssql_firewall_rule" "client" {
  name             = "AllowClient"
  server_id        = azurerm_mssql_server.this.id
  start_ip_address = var.client_ip
  end_ip_address   = var.client_ip
}

# 0.0.0.0-0.0.0.0 is the special "allow Azure-internal services" rule. It lets an
# App Service (or other Azure resource) reach the SQL server using its identity.
resource "azurerm_mssql_firewall_rule" "azure" {
  name             = "AllowAzureServices"
  server_id        = azurerm_mssql_server.this.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

output "server_fqdn" { value = azurerm_mssql_server.this.fully_qualified_domain_name }
