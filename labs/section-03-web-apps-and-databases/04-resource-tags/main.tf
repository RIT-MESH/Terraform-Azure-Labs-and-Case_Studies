# Lab 04 — Resource tags.
# Tags drive cost reporting, billing, and automation. Standardize them in locals
# and spread them with merge(). Changing var.environment retags everything.
terraform {
  required_version = ">= 1.5.0"
  required_providers { azurerm = { source = "hashicorp/azurerm", version = "~> 3.70" } }
}
provider "azurerm" { features {} }

variable "environment" { type = string, default = "dev" }

locals {
  # Common tags reused on every resource.
  common_tags = {
    environment = var.environment
    managedby   = "terraform"
    costcenter  = "cc-100"
  }
}

resource "azurerm_resource_group" "this" {
  name     = "rg-tags-${var.environment}"
  location = "eastus"
  tags     = local.common_tags
}

resource "azurerm_storage_account" "this" {
  name                     = lower("sttags${var.environment}${substr(md5(timestamp()), 0, 5)}")
  resource_group_name      = azurerm_resource_group.this.name
  location                 = azurerm_resource_group.this.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  # merge() combines common tags with one resource-specific tag.
  tags                     = merge(local.common_tags, { tier = "storage" })
}

output "rg_tags" { value = azurerm_resource_group.this.tags }
output "st_tags" { value = azurerm_storage_account.this.tags }
