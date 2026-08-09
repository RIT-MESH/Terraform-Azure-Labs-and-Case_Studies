# 14 — Output values

`output` blocks expose values to the user (printed after `apply`) and to other
configurations (via `terraform output` or remote state). This lab creates a storage
account and outputs several attributes — including a **sensitive** primary key, which
Terraform masks in logs.

```bash
terraform output
terraform output primary_access_key
```
