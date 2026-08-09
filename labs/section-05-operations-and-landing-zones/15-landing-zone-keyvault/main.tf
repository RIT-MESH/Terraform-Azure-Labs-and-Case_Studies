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
