# Lab 05 — the change → plan → apply loop.
# A storage account + container + a blob with source_content. Change the blob's
# source_content, then `terraform plan` shows the in-place update — that diff is
# how professionals review changes.
locals {
  st = lower("stchange${substr(md5(timestamp()), 0, 6)}")
}

resource "azurerm_resource_group" "this" {
  name     = "rg-changes"
  location = "eastus"
}

resource "azurerm_storage_account" "this" {
  name                     = local.st
  resource_group_name      = azurerm_resource_group.this.name
  location                 = azurerm_resource_group.this.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "data" {
  name                  = "data"
  storage_account_name  = azurerm_storage_account.this.name
  container_access_type = "private"
}

resource "azurerm_storage_blob" "readme" {
  name                   = "readme.txt"
  storage_account_name  = azurerm_storage_account.this.name
  storage_container_name = azurerm_storage_container.data.name
  type                  = "Block"
  source_content        = "Version 2 of the readme\n"
}

output "blob_url" { value = azurerm_storage_blob.readme.url }
