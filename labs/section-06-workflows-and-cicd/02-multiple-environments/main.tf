variable "environment" { type = string }
variable "location"    { type = string }
variable "tags"        { type = map(string), default = {} }

resource "azurerm_resource_group" "this" {
  name     = "rg-multi-env-${var.environment}"
  location = var.location
  tags     = var.tags
}

resource "azurerm_storage_account" "this" {
  name                     = lower("st${var.environment}${substr(md5(timestamp()), 0, 6)}")
  resource_group_name      = azurerm_resource_group.this.name
  location                 = azurerm_resource_group.this.location
  account_tier             = "Standard"
  account_replication_type = var.environment == "prod" ? "GRS" : "LRS"
  tags                     = var.tags
}

output "rg_name"      { value = azurerm_resource_group.this.name }
output "replication" { value = azurerm_storage_account.this.account_replication_type }
