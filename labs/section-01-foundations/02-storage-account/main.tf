locals {
  region   = "eastus"
  rg_name  = "rg-storage-foundation"
  # Random suffix keeps the storage account name globally unique.
  suffix   = substr(md5(timestamp()), 0, 6)
  st_name  = lower("stfoundation${local.suffix}")
}

resource "azurerm_resource_group" "this" {
  name     = local.rg_name
  location = local.region
}

resource "azurerm_storage_account" "this" {
  name                     = local.st_name
  resource_group_name      = azurerm_resource_group.this.name
  location                 = azurerm_resource_group.this.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"
  allow_blob_public_access = false
}

output "storage_account_name" {
  value = azurerm_storage_account.this.name
}

output "primary_blob_endpoint" {
  value = azurerm_storage_account.this.primary_blob_endpoint
}
