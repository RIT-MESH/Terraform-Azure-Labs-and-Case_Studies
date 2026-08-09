# 23 — `moved` block (advanced refactoring)

Rename a resource's Terraform address **without destroying and recreating** the cloud
resource. Without `moved`, renaming `azurerm_storage_account.legacy` to `.this` would
plan a destroy + create. With `moved {}`, Terraform updates the state's address in place.

```hcl
moved {
  from = azurerm_storage_account.legacy
  to   = azurerm_storage_account.this
}
```

This lab declares the resource at its new address (`this`) with a `moved` from the old
address (`legacy`). On first apply it's a no-op since there's no prior state; once you've
applied with the old name elsewhere and rename, the moved block reconciles state.

Addressing: VNet `172.16.0.0/20`, subnet `172.16.0.0/26`.
