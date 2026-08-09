# 24 — `for_each` over a data source (advanced)

`for_each` can iterate over the results of a `data` block. This lab lists the resource
groups that already exist in your subscription (`data "azurerm_resource_groups"`) and
applies a tag to each one that doesn't already carry it. It's a governance pattern:
discovery → bulk action.

> This lab modifies existing resource groups in your subscription. Run it in a sandbox
> subscription, or restrict it by using the `filter` argument of the data source.
