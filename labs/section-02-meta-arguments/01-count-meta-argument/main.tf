locals {
  rg = "rg-count-meta"
  st = lower("stcount${substr(md5(timestamp()), 0, 6)}")
}

resource "azurerm_resource_group" "this" {
  name     = local.rg
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
  count                 = 3
  name                  = "data-${count.index}"
  storage_account_name  = azurerm_storage_account.this.name
  container_access_type = "private"
}

output "container_names" {
  value = azurerm_storage_container.data[*].name
}
