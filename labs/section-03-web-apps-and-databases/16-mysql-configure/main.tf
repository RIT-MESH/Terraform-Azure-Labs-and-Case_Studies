# Lab 16 — configure the MySQL server (create a database + client firewall rule).
# We look up the EXISTING server with a data block (created in lab 15), then add a
# database and a firewall rule for your client IP so you can connect from a GUI.
terraform {
  required_version = ">= 1.5.0"
  required_providers { azurerm = { source = "hashicorp/azurerm", version = "~> 3.70" } }
}
provider "azurerm" { features {} }

variable "mysql_admin_password" { type = string, sensitive = true }
variable "existing_server_name" { type = string }
variable "existing_rg_name" { type = string }
variable "client_ip" { type = string }

# Read the existing server (we don't manage it here).
data "azurerm_mysql_flexible_server" "this" {
  name                = var.existing_server_name
  resource_group_name = var.existing_rg_name
}

# Create a database with a specific charset/collation (utf8mb4 supports emoji etc.).
resource "azurerm_mysql_flexible_database" "app" {
  name      = "dbapp"
  server_id = data.azurerm_mysql_flexible_server.this.id
  charset   = "utf8mb4"
  collation = "utf8mb4_unicode_ci"
}

# Allow YOUR client IP so you can connect with the mysql CLI or Workbench.
resource "azurerm_mysql_flexible_server_firewall_rule" "client" {
  name             = "AllowClient"
  server_id        = data.azurerm_mysql_flexible_server.this.id
  start_ip_address = var.client_ip
  end_ip_address   = var.client_ip
}

output "database_name" { value = azurerm_mysql_flexible_database.app.name }
output "mysql_fqdn"    { value = data.azurerm_mysql_flexible_server.this.fqdn }
