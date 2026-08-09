# 01 — Modules — building an Azure resource group

Start small: a module that creates **only** a resource group. This lab shows the module
contract (variables + resource + output) and how a caller consumes it.

```bash
cd labs/section-04-modules-and-networking/01-module-resource-group
terraform init   # copies the local module
terraform apply
```
