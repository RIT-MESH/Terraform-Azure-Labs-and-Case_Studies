# Lab 03 — The lifecycle meta-argument.
# lifecycle {} changes how Terraform treats a resource over time:
#   - create_before_destroy: build the new version BEFORE removing the old.
#   - prevent_destroy: refuse to destroy (safety for prod databases).
#   - ignore_changes: let chosen attributes drift (e.g. tags set by another tool).
terraform {
  required_version = ">= 1.5.0"
  required_providers { azurerm = { source = "hashicorp/azurerm", version = "~> 3.70" } }
}
provider "azurerm" { features {} }

locals { st = lower("stlife${substr(md5(timestamp()), 0, 6)}") }

resource "azurerm_resource_group" "this" {
  name     = "rg-lifecycle"
  location = "eastus"
}

resource "azurerm_storage_account" "this" {
  name                     = local.st
  resource_group_name      = azurerm_resource_group.this.name
  location                 = azurerm_resource_group.this.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags                     = { "owner" = "platform-team" }

  lifecycle {
    # Another tool (Azure Policy) retags this account. Don't fight it in plan.
    ignore_changes = [tags["owner"]]
  }
}

resource "azurerm_storage_container" "this" {
  name                  = "lifecycle"
  storage_account_name  = azurerm_storage_account.this.name
  container_access_type = "private"

  lifecycle {
    # On replace: create the NEW container first, then delete the old.
    create_before_destroy = true
  }
}
