# Modules

A **module** is a folder of Terraform files you can reuse. Reusing code reduces
duplication and enforces standards.

## Module anatomy

```
modules/vnet/
├── main.tf       # resources
├── variables.tf  # inputs
└── outputs.tf    # returned values
```

## Calling a module

```hcl
module "network" {
  source = "../../modules/vnet"

  name                = "vnet-prod"
  location            = var.location
  resource_group_name = azurerm_resource_group.core.name
  address_space       = ["10.10.0.0/16"]
}
```

Run `terraform init` so Terraform copies/links the local module.

## Module sources

| Source | Example |
|---|---|
| Local path | `source = "./modules/vnet"` |
| Git | `source = "git::https://.../infra-modules.git//vnet"` |
| Registry | `source = "Azure/vnet/azurerm"` |
| GitHub | `source = "github.com/org/repo//vnet"` |

## Good module habits

- Keep modules focused (one concern).
- Expose every tunable knob as a variable with a sensible `default`.
- Return useful `output`s so callers can chain modules.
- Version modules in source control.
