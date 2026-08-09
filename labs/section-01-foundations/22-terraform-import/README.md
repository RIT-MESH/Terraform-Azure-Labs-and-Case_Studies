# 22 — Importing existing resources (advanced)

So far every resource was *created* by Terraform. In real life you inherit resources that
already exist in Azure and want to bring them under management without recreating them.
That's what `terraform import` does.

Two ways (Terraform ≥ 1.5):

## A. The CLI one-off

```bash
terraform import azurerm_storage_account.adopted \
  /subscriptions/<sub>/resourceGroups/<rg>/providers/Microsoft.Storage/storageAccounts/<name>
```

This writes the resource into state; you then write the matching `resource` block.

## B. The declarative `import` block (reusable, lives in code)

Declare both the `import` and the `resource`. Run `terraform plan` — Terraform reads the
existing resource, shows what it would record, and on `apply` binds the address.

## Run this lab

1. Create a storage account **outside** Terraform first:

   ```bash
   az group create -n rg-import-demo -l eastus
   az storage account create -n stimportdemo<random> -g rg-import-demo --sku Standard_LRS
   ```

2. Set the two variables (copy `terraform.tfvars.example`) and run:

   ```bash
   terraform init
   terraform plan     # Terraform imports the existing account, no changes
   terraform apply    # records it in state
   ```
