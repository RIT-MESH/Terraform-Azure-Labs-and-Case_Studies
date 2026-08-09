variable "location"    { type = string }
variable "name_prefix" { type = string }
variable "tier"        { type = string }

resource "azurerm_resource_group" "this" {
  name     = "rg-tfvars-foundation"
  location = var.location
}

resource "azurerm_storage_account" "this" {
  name                     = "${var.name_prefix}${substr(md5(timestamp()), 0, 6)}"
  resource_group_name      = azurerm_resource_group.this.name
  location                 = azurerm_resource_group.this.location
  account_tier             = var.tier
  account_replication_type = "LRS"
}
