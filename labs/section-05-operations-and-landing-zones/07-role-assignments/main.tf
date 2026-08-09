data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "this" {
  name     = "rg-rbac"
  location = "eastus"
}

# Grant the current user Reader on the resource group.
resource "azurerm_role_assignment" "current_reader" {
  scope                = azurerm_resource_group.this.id
  role_definition_name = "Reader"
  principal_id         = data.azurerm_client_config.current.object_id
}

output "assignment_id" { value = azurerm_role_assignment.current_reader.id }
