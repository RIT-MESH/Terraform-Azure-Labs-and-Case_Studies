# Variables make a configuration REUSABLE. Each variable can have a type, a
# default, a description, and validation rules. Override via tfvars, -var, or
# the TF_VAR_<name> environment variable.
variable "location" {
  type        = string
  default     = "eastus"
  description = "Azure region."
}

variable "name_prefix" {
  type        = string
  default     = "stvar"
  description = "Lowercase prefix for the storage account (3-18 chars, alnum only)."

  # validation runs BEFORE plan. can() returns true if the expression succeeds.
  validation {
    condition     = can(regex("^[a-z0-9]{3,18}$", var.name_prefix))
    error_message = "name_prefix must be 3-18 lowercase alphanumerics."
  }
}

variable "tier" {
  type        = string
  default     = "Standard"
  description = "Storage account tier."

  # contains() checks membership in a list — restrict to allowed values.
  validation {
    condition     = contains(["Standard", "Premium"], var.tier)
    error_message = "tier must be Standard or Premium."
  }
}

locals {
  rg = "rg-vars-foundation"
  st = "${var.name_prefix}${substr(md5(timestamp()), 0, 6)}"   # prefix + suffix
}

resource "azurerm_resource_group" "this" {
  name     = local.rg
  location = var.location
}

resource "azurerm_storage_account" "this" {
  name                     = local.st
  resource_group_name      = azurerm_resource_group.this.name
  location                 = azurerm_resource_group.this.location
  account_tier             = var.tier           # from the validated variable
  account_replication_type = "LRS"
}
