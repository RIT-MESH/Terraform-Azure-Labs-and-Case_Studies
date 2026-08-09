# 02 — Azure Storage Account

Your first real resource. Create a resource group and a general-purpose v2 storage
account, then use `terraform import` to understand the read path.

```bash
terraform init
terraform plan
terraform apply
```

Key points:

- Storage account names are **globally unique** and lowercase, 3–24 chars, alphanumerics
  only. We derive the name from a prefix + random suffix.
- `azurerm_resource_group` is the almost-always-first resource in any Azure config.
