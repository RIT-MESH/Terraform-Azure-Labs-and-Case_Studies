# 04 — References to named values

Terraform references let one resource consume another's attributes. This lab
demonstrates the three reference families:

| Reference | Looks like | Refers to |
|---|---|---|
| Resource | `azurerm_resource_group.core.id` | another resource attribute |
| Local | `local.rg_name` | a value in `locals {}` |
| Variable | `var.location` | an input variable |

The same storage account is created, but every attribute is now *referenced* rather than
repeated — the single source of truth pattern you should use everywhere.
