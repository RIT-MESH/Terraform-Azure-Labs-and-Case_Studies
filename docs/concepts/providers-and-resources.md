# Providers and resources

Terraform talks to clouds through **providers**. For Azure we use the official
`hashicorp/azurerm` provider.

## The provider block

```hcl
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.70"
    }
  }
}

provider "azurerm" {
  features {}
}
```

`required_providers` pins the source and version so the code is reproducible. The
`features {}` block is required by `azurerm` even when empty.

## The resource block

A resource is the unit of infrastructure:

```hcl
resource "azurerm_resource_group" "core" {
  name     = "rg-core-prod"
  location = "eastus"
}
```

- `resource` — the block type.
- `"azurerm_resource_group"` — the resource **type** (provider prefix + kind).
- `"core"` — the **local name** you use to reference it: `azurerm_resource_group.core.id`.

## Reference syntax

```hcl
resource "azurerm_storage_account" "logs" {
  name                = "stlogscorprod"
  resource_group_name = azurerm_resource_group.core.name   # reference another resource
  location            = azurerm_resource_group.core.location
  ...
}
```

## Resource behaviour

- `terraform plan` diffs the desired state against the real cloud and proposes changes.
- `terraform apply` makes those changes.
- Resources are created in dependency order, which Terraform derives from references.
