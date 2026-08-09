# Lab 18 — deploy a web app that points at a MySQL database.
# The MySQL connection string is built from the server (declared here) and stored
# in the web app's app_settings.
terraform {
  required_version = ">= 1.5.0"
  required_providers { azurerm = { source = "hashicorp/azurerm", version = "~> 3.70" } }
}
provider "azurerm" { features {} }

variable "mysql_admin_password" { type = string, sensitive = true }

resource "azurerm_resource_group" "this" {
  name     = "rg-webapp-mysql"
  location = "eastus"
}

resource "azurerm_mysql_flexible_server" "this" {
  name                   = "mysql-web-${substr(md5(timestamp()), 0, 12)}"
  resource_group_name    = azurerm_resource_group.this.name
  location               = azurerm_resource_group.this.location
  administrator_login    = "mysqladmin"
  administrator_password = var.mysql_admin_password
  sku_name               = "B_Standard_B1ms"
  version                = "8.0.21"
  storage_mb             = 20480
}

resource "azurerm_mysql_flexible_database" "app" {
  name      = "dbapp"
  server_id = azurerm_mysql_flexible_server.this.id
  charset   = "utf8mb4"
  collation = "utf8mb4_unicode_ci"
}

resource "azurerm_service_plan" "this" {
  name                = "asp-webapp-mysql"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  os_type             = "Linux"
  sku_name            = "B1"
}

resource "azurerm_linux_web_app" "this" {
  name                = "app-mysql-${substr(md5(timestamp()), 0, 8)}"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  service_plan_id     = azurerm_service_plan.this.id
  site_config {
    application_stack { node_version = "18-lts" }
  }

  # DATABASE_URL = mysql://user:pass@host:3306/dbname
  app_settings = {
    "DATABASE_URL" = "mysql://mysqladmin:${var.mysql_admin_password}@${azurerm_mysql_flexible_server.this.fqdn}:3306/${azurerm_mysql_flexible_database.app.name}"
  }
}

output "webapp_hostname" { value = azurerm_linux_web_app.this.default_hostname }
output "mysql_fqdn"      { value = azurerm_mysql_flexible_server.this.fqdn }
