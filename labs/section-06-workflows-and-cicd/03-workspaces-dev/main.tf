# Lab 03 — Terraform workspaces (one config, several state files).
# terraform.workspace is the current workspace name (dev/prod/etc.).
#  - terraform workspace new dev / select dev
#  - names and SKU tiers derive from terraform.workspace.
# Best for SAME-SHAPE environments. For different shapes, use separate directories.
terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = { source = "hashicorp/azurerm", version = "~> 3.70" }
  }
}
provider "azurerm" { features {} }

locals {
  env   = terraform.workspace
  rg    = "rg-ws-${local.env}"
  replication = local.env == "prod" ? "GRS" : "LRS"
}

resource "azurerm_resource_group" "this" {
  name     = local.rg
  location = "eastus"
}

resource "azurerm_storage_account" "this" {
  name                     = lower("stws${local.env}${substr(md5(timestamp()), 0, 5)}")
  resource_group_name      = azurerm_resource_group.this.name
  location                 = azurerm_resource_group.this.location
  account_tier             = "Standard"
  account_replication_type = local.replication
  tags                     = { environment = local.env }
}

output "workspace"    { value = local.env }
output "rg_name"       { value = azurerm_resource_group.this.name }
output "replication"   { value = azurerm_storage_account.this.account_replication_type }
