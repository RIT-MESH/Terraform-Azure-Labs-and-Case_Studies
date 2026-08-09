variable "mysql_admin_password" { type = string, sensitive = true }
variable "existing_server_name" { type = string }
variable "existing_rg_name" { type = string }
variable "client_ip" { type = string }

data "azurerm_mysql_flexible_server" "this" {
  name                = var.existing_server_name
  resource_group_name = var.existing_rg_name
}

resource "azurerm_mysql_flexible_database" "app" {
  name      = "dbapp"
  server_id = data.azurerm_mysql_flexible_server.this.id
  charset   = "utf8mb4"
  collation = "utf8mb4_unicode_ci"
}

resource "azurerm_mysql_flexible_server_firewall_rule" "client" {
  name             = "AllowClient"
  server_id        = data.azurerm_mysql_flexible_server.this.id
  start_ip_address = var.client_ip
  end_ip_address   = var.client_ip
}

output "database_name" { value = azurerm_mysql_flexible_database.app.name }
output "mysql_fqdn"    { value = data.azurerm_mysql_flexible_server.this.fqdn }
