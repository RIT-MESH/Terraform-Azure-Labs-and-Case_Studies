# State management

Terraform stores a mapping between your configuration and the real cloud resources in a
**state file** (`terraform.tfstate`).

## Local state (default)

For learning this is fine. The file lives in the lab folder.

## Why move to remote state

- **Team sharing** — everyone reads the same source of truth.
- **Locking** — prevents concurrent `apply` from corrupting state.
- **Secrets off laptops** — the state file can contain sensitive values.

## Remote state on Azure Storage

See [section-06 / 16-remote-state-storage](../../labs/section-06-workflows-and-cicd/16-remote-state-storage/).

```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "rg-tfstate"
    storage_account_name = "sttfstateprod"
    container_name        = "tfstate"
    key                  = " foundations.tfstate"
  }
}
```

## Commands

| Command | Purpose |
|---|---|
| `terraform init` | Initialise, download providers, configure backend |
| `terraform plan` | Show the change preview |
| `terraform apply` | Apply changes |
| `terraform destroy` | Destroy all resources in the config |
| `terraform state list` | List resources in state |
| `terraform state mv` | Rename a resource in state |
| `terraform fmt` | Format code |
| `terraform validate` | Static checks |
