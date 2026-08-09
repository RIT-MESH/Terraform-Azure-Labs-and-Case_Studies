resource "azurerm_resource_group" "this" {
  name     = "rg-locks"
  location = "eastus"
}

resource "azurerm_storage_account" "this" {
  name                     = lower("stlock${substr(md5(timestamp()), 0, 6)}")
  resource_group_name      = azurerm_resource_group.this.name
  location                 = azurerm_resource_group.this.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_management_lock" "st" {
  name       = "do-not-delete"
  scope      = azurerm_storage_account.this.id
  lock_level = "CanNotDelete"
  notes      = "Protected by Terraform; remove lock before destroying."
}

output "lock_id" { value = azurerm_management_lock.st.id }
