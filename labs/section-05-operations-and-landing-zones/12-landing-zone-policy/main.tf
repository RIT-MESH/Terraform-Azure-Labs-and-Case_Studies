resource "azurerm_resource_group" "this" {
  name     = "rg-lz-policy"
  location = "eastus"
}

# Built-in: allowed storage account SKUs (definition id is fixed per environment;
# use the data source to look it up by display name).
data "azurerm_policy_definition" "allowed_storage_skus" {
  display_name = "Allowed storage account SKUs"
}

resource "azurerm_resource_group_policy_assignment" "allowed_storage_skus" {
  name                 = "allowed-storage-skus"
  resource_group_id    = azurerm_resource_group.this.id
  policy_definition_id = data.azurerm_policy_definition.allowed_storage_skus.id
  description           = "Restrict storage SKUs in the landing zone."
  display_name         = "Allowed storage account SKUs"

  parameters = jsonencode({
    listOfAllowedSKUs = {
      value = ["Standard_LRS", "Standard_GRS"]
    }
  })
}

output "assignment_id" { value = azurerm_resource_group_policy_assignment.allowed_storage_skus.id }
