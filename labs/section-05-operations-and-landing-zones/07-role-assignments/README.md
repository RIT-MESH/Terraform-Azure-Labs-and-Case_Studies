# 07 — Role assignments via Terraform

`azurerm_role_assignment` grants an Azure RBAC role to a principal on a scope. This lab
creates a resource group and grants the current signed-in user the **Reader** role, plus
a fictional SP the **Contributor** role.

Use a `data "azurerm_client_config"` to get the current principal, and the built-in role
definition IDs are addressed by name with `azurerm_role_definition` data source.
