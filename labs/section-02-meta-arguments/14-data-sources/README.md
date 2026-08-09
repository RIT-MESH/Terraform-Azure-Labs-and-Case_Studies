# 14 — Data sources

`data` blocks **read** existing resources instead of creating them. This lab looks up an
existing resource group and uses its attributes to create a storage account — without
owning the resource group.

```hcl
data "azurerm_resource_group" "existing" {
  name = "rg-already-here"
}
```

Run it after creating a resource group named `rg-already-here` (lab 02 creates one you
could point at), or change the name to suit your subscription.
