# Lab 13 — Azure Key Vault.
# Key Vault stores secrets/keys/certs centrally so they never sit in code or state
# on a laptop. We create a vault, grant the current user access, and store a secret.
terraform {
  required_version = ">= 1.5.0"
  required_providers { azurerm = { source = "hashicorp/azurerm", version = "~> 3.70" } }
}
provider "azurerm" { features {} }

# Read the current signed-in principal (object_id) to grant it permissions.
data "azurerm_client_config" "current" {}

locals {
  # Vault names are globally unique, 3-24 chars, alphanumerics + hyphens only.
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
  soft_delete_retention_days = 7     # recover deleted secrets for 7 days
  purge_protection_enabled   = false # lab: allow hard purge; enable in prod

  # access_policy grants a principal (here: you) permissions on the vault.
  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id
    secret_permissions = ["Get", "List", "Set", "Delete", "Purge"]
  }
}

# A secret stored in the vault. The VALUE is sensitive; it stays in the vault.
resource "azurerm_key_vault_secret" "db_password" {
  name         = "db-password"
  value        = "SuperSecret-${substr(md5(timestamp()), 0, 8)}"
  key_vault_id = azurerm_key_vault.this.id
}

output "vault_name" { value = azurerm_key_vault.this.name }
# versionless_id is a stable reference to the secret (not the value).
output "secret_versionless_id" {
  value     = azurerm_key_vault_secret.db_password.versionless_id
  sensitive = true
}
