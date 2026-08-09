# Lab 22 — SQL server with Microsoft Entra ID (Azure AD) admin.
# Entra ID admin lets you sign in with an identity (no shared password). We also
# enable a SystemAssigned managed identity so the server can later authenticate
# to other Azure resources without secrets.
terraform {
  required_version = ">= 1.5.0"
  required_providers { azurerm = { source = "hashicorp/azurerm", version = "~> 3.70" } }
}
provider "azurerm" { features {} }

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "this" {
  name     = "rg-sql-entra"
  location = "eastus"
}

resource "azurerm_mssql_server" "this" {
  name                = "sql-entra-${substr(md5(timestamp()), 0, 8)}"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  version             = "12.0"

  # A SQL login for bootstrapping; Entra admin is the primary auth path.
  administrator_login          = "sqladmin"
  administrator_login_password = "ChangeMe12345!"
  minimum_tls_version          = "1.2"

  # Set the Entra admin to the current signed-in principal.
  azuread_administrator {
    login_username = "EntraAdmin"
    object_id      = data.azurerm_client_config.current.object_id
    tenant_id      = data.azurerm_client_config.current.tenant_id
  }

  identity { type = "SystemAssigned" }   # server gets a managed identity
}

resource "azurerm_mssql_database" "this" {
  name      = "sqldb-entra"
  server_id = azurerm_mssql_server.this.id
  sku_name  = "Basic"
}

output "server_fqdn" { value = azurerm_mssql_server.this.fully_qualified_domain_name }
