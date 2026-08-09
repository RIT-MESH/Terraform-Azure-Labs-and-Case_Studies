locals {
  st = lower("stlife${substr(md5(timestamp()), 0, 6)}")
}

resource "azurerm_resource_group" "this" {
  name     = "rg-lifecycle"
  location = "eastus"
}

resource "azurerm_storage_account" "this" {
  name                     = local.st
  resource_group_name      = azurerm_resource_group.this.name
  location                 = azurerm_resource_group.this.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags                     = { "owner" = "platform-team" }

  lifecycle {
    # The platform team retags this account in Azure Policy; don't fight it.
    ignore_changes = [tags["owner"]]
  }
}

resource "azurerm_storage_container" "this" {
  name                  = "lifecycle"
  storage_account_name  = azurerm_storage_account.this.name
  container_access_type = "private"

  lifecycle {
    create_before_destroy = true
  }
}
