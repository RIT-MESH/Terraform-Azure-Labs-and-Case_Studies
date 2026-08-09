data "azurerm_client_config" "current" {}

locals {
  vault_name = "kv-${substr(md5(timestamp()), 0, 18)}"
}

resource "azurerm_resource_group" "this" {
  name     = "rg-kv-meta"
  location = "eastus"
}

resource "azurerm_key_vault" "this" {
  name                       = local.vault_name
  location                   = azurerm_resource_group.this.location
  resource_group_name        = azurerm_resource_group.this.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  soft_delete_retention_days = 7
  purge_protection_enabled   = false

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    secret_permissions = ["Get", "List", "Set", "Delete", "Purge"]
  }
}

resource "azurerm_key_vault_secret" "db_password" {
  name         = "db-password"
  value        = "SuperSecret-${substr(md5(timestamp()), 0, 8)}"
  key_vault_id = azurerm_key_vault.this.id
}

output "vault_name"      { value = azurerm_key_vault.this.name }
output "secret_versionless_id" {
  value     = azurerm_key_vault_secret.db_password.versionless_id
  sensitive = true
}
