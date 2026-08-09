# Lab 12 — the built-in `terraform test` framework (.tftest.hcl).
# main.tf: a storage account whose tier is a variable.
# tests/main.tftest.hcl: `run` blocks with `command = plan` and `assert` checks:
#   - exactly one storage account in the plan,
#   - its tier is Standard.
# Run: terraform init && terraform test. (plan-only assertions need no real resources.)
terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = { source = "hashicorp/azurerm", version = "~> 3.70" }
  }
}
provider "azurerm" { features {} }

resource "azurerm_resource_group" "this" {
  name     = "rg-tftest"
  location = "eastus"
}

resource "azurerm_storage_account" "this" {
  name                     = lower("sttftest${substr(md5(timestamp()), 0, 6)}")
  resource_group_name      = azurerm_resource_group.this.name
  location                 = azurerm_resource_group.this.location
  account_tier             = var.tier
  account_replication_type = "LRS"
}

output "storage_name" { value = azurerm_storage_account.this.name }
