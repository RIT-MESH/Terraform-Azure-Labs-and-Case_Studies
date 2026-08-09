# Lab 04 — RBAC role assignment via Terraform.
# azurerm_role_assignment grants a role (by name) to a principal on a scope.
# Here we grant the current signed-in user the built-in "Reader" role on a resource
# group. role_definition_name resolves to the built-in role's id automatically.
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
