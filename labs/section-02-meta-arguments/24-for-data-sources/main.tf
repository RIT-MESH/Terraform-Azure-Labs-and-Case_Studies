# Lab 24 — for_each over a data block (discovery pattern).
# List existing resource groups, then iterate them. Governance: discover → act.
# CAUTION: this reads existing RGs in your subscription. Run in a sandbox.
terraform {
  required_version = ">= 1.5.0"
  required_providers { azurerm = { source = "hashicorp/azurerm", version = "~> 3.70" } }
}
provider "azurerm" { features {} }

# Discover existing resource groups in the current subscription.
data "azurerm_resource_groups" "existing" {}

locals {
  # Build a map name -> id from the discovered list, for for_each.
  by_name = {
    for rg in data.azurerm_resource_groups.existing.resource_groups :
    rg.name => rg.id
  }
}

# Re-declare each existing RG as a data source so we can surface its attributes.
data "azurerm_resource_group" "each" {
  for_each = local.by_name
  name     = each.key
}

output "discovered_rg_count" { value = length(local.by_name) }
output "discovered_rg_names" { value = keys(local.by_name) }
