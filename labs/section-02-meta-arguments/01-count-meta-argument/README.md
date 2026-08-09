# 01 — The `count` meta-argument

`count` creates N copies of a resource. Each copy is addressed as `resource.name[0]`,
`resource.name[1]`, etc. Use `count` when the copies are **identical and indexed**.

This lab makes three storage containers (`data-0`, `data-1`, `data-2`) from one block.

```hcl
resource "azurerm_storage_container" "data" {
  count  = 3
  name   = "data-${count.index}"
  ...
}
```
