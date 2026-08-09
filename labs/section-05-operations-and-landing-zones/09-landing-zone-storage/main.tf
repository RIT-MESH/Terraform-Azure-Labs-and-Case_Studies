# Lab 09 — Landing Zone: app storage.
# A general-purpose v2 storage account with two private containers and TLS 1.2
# enforced. Lives in the data RG; public blob access is OFF.
resource "azurerm_resource_group" "data" {
  name     = "rg-lz-data"
  location = "eastus"
}

resource "azurerm_storage_account" "app" {
  name                     = lower("stlzapp${substr(md5(timestamp()), 0, 6)}")
  resource_group_name      = azurerm_resource_group.data.name
  location                 = azurerm_resource_group.data.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"
  allow_blob_public_access = false
}

resource "azurerm_storage_container" "uploads" {
  name                  = "uploads"
  storage_account_name  = azurerm_storage_account.app.name
  container_access_type = "private"
}

resource "azurerm_storage_container" "archive" {
  name                  = "archive"
  storage_account_name  = azurerm_storage_account.app.name
  container_access_type = "private"
}

output "storage_name" { value = azurerm_storage_account.app.name }
