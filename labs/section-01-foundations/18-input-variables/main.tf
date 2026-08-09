variable "location" {
  type        = string
  default     = "eastus"
  description = "Azure region."
}

variable "name_prefix" {
  type        = string
  default     = "stvar"
  description = "Lowercase prefix for the storage account (3-18 chars, alnum only)."

  validation {
    condition     = can(regex("^[a-z0-9]{3,18}$", var.name_prefix))
    error_message = "name_prefix must be 3-18 lowercase alphanumerics."
  }
}

variable "tier" {
  type        = string
  default     = "Standard"
  description = "Storage account tier."

  validation {
    condition     = contains(["Standard", "Premium"], var.tier)
    error_message = "tier must be Standard or Premium."
  }
}

locals {
  rg     = "rg-vars-foundation"
  st     = "${var.name_prefix}${substr(md5(timestamp()), 0, 6)}"
}

resource "azurerm_resource_group" "this" {
  name     = local.rg
  location = var.location
}

resource "azurerm_storage_account" "this" {
  name                     = local.st
  resource_group_name      = azurerm_resource_group.this.name
  location                 = azurerm_resource_group.this.location
  account_tier             = var.tier
  account_replication_type = "LRS"
}
