# Read an existing resource group we do NOT manage here.
data "azurerm_resource_group" "existing" {
  name = var.existing_rg_name
}

resource "azurerm_storage_account" "this" {
  name                     = lower("stdata${substr(md5(timestamp()), 0, 6)}")
  resource_group_name      = data.azurerm_resource_group.existing.name
  location                 = data.azurerm_resource_group.existing.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

output "rg_location" { value = data.azurerm_resource_group.existing.location }
output "rg_tags"     { value = data.azurerm_resource_group.existing.tags }
