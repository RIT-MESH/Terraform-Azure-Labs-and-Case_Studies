# 03 — Upload a Blob

Create a storage account, a container, and upload a small text file as a block blob
using `azurerm_storage_blob`.

## What you learn

- `azurerm_storage_container` controls blob grouping + access tier.
- `azurerm_storage_blob` with `source` uploads a local file.
- The `data` argument accepts inline bytes; `source` accepts a file path.

## Try it

```bash
terraform init
terraform apply
```

Then inspect the uploaded blob:

```bash
az storage blob show --account-name <name> --container-name uploads --name hello.txt
```
