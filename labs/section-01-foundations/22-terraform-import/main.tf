terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = { source = "hashicorp/azurerm", version = "~> 3.70" }
  }
}
provider "azurerm" { features {} }

data "azurerm_client_config" "current" {}

variable "existing_sa_name" {
  type        = string
  description = "Storage account that already exists in Azure (created outside Terraform)."
}

variable "existing_rg_name" {
  type = string
}

locals {
  # Build the Azure resource id of the pre-existing storage account.
  sa_id = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${var.existing_rg_name}/providers/Microsoft.Storage/storageAccounts/${var.existing_sa_name}"
}

# Declarative import: bind the existing resource to this address on the next apply.
import {
  to = azurerm_storage_account.adopted
  id = local.sa_id
}

resource "azurerm_storage_account" "adopted" {
  name                     = var.existing_sa_name
  resource_group_name      = var.existing_rg_name
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

output "adopted_id" { value = azurerm_storage_account.adopted.id }
