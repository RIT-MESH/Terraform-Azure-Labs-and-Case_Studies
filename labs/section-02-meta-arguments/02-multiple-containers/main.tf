# Lab 02 — count from a variable (assignment).
# Same as lab 01 but the count is driven by a variable, so callers change the
# number of containers via tfvars/CLI without editing code.
terraform {
  required_version = ">= 1.5.0"
  required_providers { azurerm = { source = "hashicorp/azurerm", version = "~> 3.70" } }
}
provider "azurerm" { features {} }

variable "container_count" {
  type    = number
  default = 3
  validation {
    condition     = var.container_count > 0 && var.container_count <= 10
    error_message = "Keep between 1 and 10."
  }
}

locals {
  st = lower("stcont${substr(md5(timestamp()), 0, 6)}")
}

resource "azurerm_resource_group" "this" {
  name     = "rg-multi-containers"
  location = "eastus"
}

resource "azurerm_storage_account" "this" {
  name                     = local.st
  resource_group_name      = azurerm_resource_group.this.name
  location                 = azurerm_resource_group.this.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# count comes from the variable now. Try: terraform apply -var=container_count=5
resource "azurerm_storage_container" "data" {
  count                 = var.container_count
  name                  = "tier-${count.index}"
  storage_account_name  = azurerm_storage_account.this.name
  container_access_type = "private"
}

output "count"           { value = length(azurerm_storage_container.data) }
output "container_names" { value = azurerm_storage_container.data[*].name }
