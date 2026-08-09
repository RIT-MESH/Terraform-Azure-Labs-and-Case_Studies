terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = { source = "hashicorp/azurerm", version = "~> 3.70" }
  }
}
provider "azurerm" { features {} }

# Discover existing resource groups in the current subscription.
data "azurerm_resource_groups" "existing" {}

locals {
  # Build a map of resource group name -> id for iteration.
  by_name = {
    for rg in data.azurerm_resource_groups.existing.resource_groups :
    rg.name => rg.id
  }
}

# Re-declare each existing RG (read-only here) so we can surface it as output.
data "azurerm_resource_group" "each" {
  for_each = local.by_name
  name     = each.key
}

output "discovered_rg_count" { value = length(local.by_name) }
output "discovered_rg_names" { value = keys(local.by_name) }
