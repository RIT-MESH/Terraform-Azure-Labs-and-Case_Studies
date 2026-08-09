# Lab 15 — Azure Database for MySQL (Flexible Server).
# A managed MySQL 8 instance. Burstable B1ms is the smallest. Public access + a
# firewall rule for Azure services lets apps reach it.
terraform {
  required_version = ">= 1.5.0"
  required_providers { azurerm = { source = "hashicorp/azurerm", version = "~> 3.70" } }
}
provider "azurerm" { features {} }

variable "mysql_admin_password" { type = string, sensitive = true }

resource "azurerm_resource_group" "this" {
  name     = "rg-mysql"
  location = "eastus"
}

resource "azurerm_mysql_flexible_server" "this" {
  name                   = "mysql-${substr(md5(timestamp()), 0, 12)}"
  resource_group_name    = azurerm_resource_group.this.name
  location               = azurerm_resource_group.this.location
  administrator_login    = "mysqladmin"
  administrator_password = var.mysql_admin_password
  sku_name               = "B_Standard_B1ms"   # burstable, 1 vCPU, 2GB
  version                = "8.0.21"
  storage_mb             = 20480

  public_network_access_enabled = true   # allow connections from Azure services
}

# 0.0.0.0 = allow any Azure-internal IP to connect (so App Service can).
resource "azurerm_mysql_flexible_server_firewall_rule" "azure" {
  name             = "AllowAzure"
  server_id        = azurerm_mysql_flexible_server.this.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

output "mysql_fqdn" { value = azurerm_mysql_flexible_server.this.fqdn }
