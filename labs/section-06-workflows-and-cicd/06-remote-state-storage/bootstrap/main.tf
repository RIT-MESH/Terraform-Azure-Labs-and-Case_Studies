terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = { source = "hashicorp/azurerm", version = "~> 3.70" }
  }
}
provider "azurerm" { features {} }

locals {
  rg     = "rg-tfstate"
  st     = lower("sttfstate${substr(md5(timestamp()), 0, 6)}")
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
  min_tls_version          = "TLS1_2"
  allow_blob_public_access = false
}

resource "azurerm_storage_container" "tfstate" {
  name                  = "tfstate"
  storage_account_name  = azurerm_storage_account.this.name
  container_access_type = "private"
}

output "resource_group_name"  { value = azurerm_resource_group.this.name }
output "storage_account_name" { value = azurerm_storage_account.this.name }
output "container_name"       { value = azurerm_storage_container.tfstate.name }
