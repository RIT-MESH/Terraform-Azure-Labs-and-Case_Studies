# Lab 13 — author a CUSTOM Azure Policy definition + assign it.
#  - azurerm_policy_definition: policyRule JSON — deny resource groups missing a
#    "costcenter" tag. Stored at the subscription scope.
#  - azurerm_resource_group_policy_assignment assigns the custom definition to an RG.
terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = { source = "hashicorp/azurerm", version = "~> 3.70" }
  }
}
provider "azurerm" { features {} }

resource "azurerm_resource_group" "this" {
  name     = "rg-custom-policy"
  location = "eastus"
  tags     = { costcenter = "cc-100" } # compliant with our own policy
}

# A custom policy definition (stored at the subscription scope).
resource "azurerm_policy_definition" "require_costcenter" {
  name         = "require-costcenter-tag"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "Require a costcenter tag on resource groups"

  policy_rule = jsonencode({
    if = {
      allOf = [
        { field = "type", equals = "Microsoft.Resources/resourceGroups" },
        { field = "tags.costcenter", exists = "false" },
      ]
    }
    then = { effect = "deny" }
  })

  parameters = jsonencode({})
}

# Assign the custom definition to our resource group.
resource "azurerm_resource_group_policy_assignment" "this" {
  name                 = "require-costcenter-rg"
  resource_group_id    = azurerm_resource_group.this.id
  policy_definition_id = azurerm_policy_definition.require_costcenter.id
  display_name         = "Require costcenter tag"
  description          = "Deny resource groups missing a costcenter tag."
}

output "definition_id" { value = azurerm_policy_definition.require_costcenter.id }
