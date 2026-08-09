# Lab 14 — connect a web app to a SQL database.
# We inject the SQL connection string into the app's app_settings. Marking it
# sensitive in the setting keeps it out of plain logs. The SQL firewall rule
# 0.0.0.0 lets the Azure-hosted app reach the SQL server.
terraform {
  required_version = ">= 1.5.0"
  required_providers { azurerm = { source = "hashicorp/azurerm", version = "~> 3.70" } }
}
provider "azurerm" { features {} }

variable "sql_admin_password" { type = string, sensitive = true }

resource "azurerm_resource_group" "this" {
  name     = "rg-webapp-sql"
  location = "eastus"
}

resource "azurerm_mssql_server" "this" {
  name                         = "sqlserver-webapp-${substr(md5(timestamp()), 0, 8)}"
  resource_group_name          = azurerm_resource_group.this.name
  location                     = azurerm_resource_group.this.location
  version                      = "12.0"
  administrator_login          = "sqladmin"
  administrator_login_password = var.sql_admin_password
}

# Allow Azure-internal services (like our App Service) to reach the SQL server.
resource "azurerm_mssql_firewall_rule" "azure" {
  name             = "AllowAzure"
  server_id        = azurerm_mssql_server.this.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

resource "azurerm_mssql_database" "this" {
  name      = "sqldb-webapp"
  server_id = azurerm_mssql_server.this.id
  sku_name  = "Basic"
}

resource "azurerm_service_plan" "this" {
  name                = "asp-webapp-sql"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  os_type             = "Linux"
  sku_name            = "B1"
}

resource "azurerm_linux_web_app" "this" {
  name                = "app-webapp-sql-${substr(md5(timestamp()), 0, 8)}"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  service_plan_id     = azurerm_service_plan.this.id
  site_config {
    application_stack { node_version = "18-lts" }
  }

  # app_settings are environment variables for the app. The connection string is
  # built from the server/database + the sensitive password.
  app_settings = {
    "DATABASE_URL" = "Server=tcp:${azurerm_mssql_server.this.fully_qualified_domain_name},1433;Database=${azurerm_mssql_database.this.name};User Id=sqladmin;Password=${var.sql_admin_password};Encrypt=true;"
  }
}

output "webapp_hostname" { value = azurerm_linux_web_app.this.default_hostname }
output "sql_fqdn"        { value = azurerm_mssql_server.this.fully_qualified_domain_name }
