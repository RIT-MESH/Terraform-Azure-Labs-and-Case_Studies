# Lab 23 — MySQL Flexible Server: configuration + zone-redundant HA.
# Beyond basics: set high_availability = ZoneRedundant (2 instances across zones),
# tune a server parameter (max_connections), and set a maintenance window.
terraform {
  required_version = ">= 1.5.0"
  required_providers { azurerm = { source = "hashicorp/azurerm", version = "~> 3.70" } }
}
provider "azurerm" { features {} }

variable "mysql_admin_password" { type = string, sensitive = true }

resource "azurerm_resource_group" "this" {
  name     = "rg-mysql-adv"
  location = "eastus"
}

resource "azurerm_mysql_flexible_server" "this" {
  name                   = "mysql-adv-${substr(md5(timestamp()), 0, 12)}"
  resource_group_name    = azurerm_resource_group.this.name
  location               = azurerm_resource_group.this.location
  administrator_login    = "mysqladmin"
  administrator_password = var.mysql_admin_password
  sku_name               = "B_Standard_B1ms"
  version                = "8.0.21"
  storage_mb             = 20480
  zone                   = "1"   # primary instance pinned to zone 1

  # Zone-redundant HA: a standby replica in another zone → automatic failover.
  high_availability {
    mode = "ZoneRedundant"
  }

  # Patching only during this weekly window (Sunday 02:00).
  maintenance_window {
    day_of_week  = 0
    start_hour   = 2
    start_minute = 0
  }
}

# Tune a single server parameter (max_connections).
resource "azurerm_mysql_flexible_server_configuration" "max_conn" {
  name                = "max_connections"
  resource_group_name = azurerm_resource_group.this.name
  server_name         = azurerm_mysql_flexible_server.this.name
  value               = "200"
}

output "mysql_fqdn" { value = azurerm_mysql_flexible_server.this.fqdn }
