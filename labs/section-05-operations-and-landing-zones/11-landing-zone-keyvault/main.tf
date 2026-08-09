# Lab 11 — Landing Zone: Key Vault.
#  - A vault in the security RG; purge protection enabled (certs/secrets can't be
#    hard-deleted for 7 days).
#  - An access policy granting the current user Get/Set/Delete/Purge on secrets.
#  - One stored secret (sql-admin-password) the app can pull at runtime.
data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "sec" {
  name     = "rg-lz-kv"
  location = "eastus"
}

resource "azurerm_key_vault" "this" {
  name                       = "kv-lz-${substr(md5(timestamp()), 0, 12)}"
  location                   = azurerm_resource_group.sec.location
  resource_group_name        = azurerm_resource_group.sec.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  soft_delete_retention_days = 7
  purge_protection_enabled   = true

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id
    secret_permissions = ["Get", "List", "Set", "Delete", "Purge", "Recover"]
  }
}

resource "azurerm_key_vault_secret" "sql_admin" {
  name         = "sql-admin-password"
  value        = "ChangeMe-${substr(md5(timestamp()), 0, 8)}"
  key_vault_id = azurerm_key_vault.this.id
}

output "vault_name" { value = azurerm_key_vault.this.name }
