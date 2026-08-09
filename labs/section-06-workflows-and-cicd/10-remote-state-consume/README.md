# 10 — `terraform_remote_state` — consume another stack's outputs (advanced)

Two configs that don't know each other's code, only each other's **state**. `base/`
creates a storage account and outputs its name. `consumer/` reads `base`'s state with
`data "terraform_remote_state"` and creates a container inside that storage account.

```bash
cd base && terraform init && terraform apply      # produces terraform.tfstate
cd ../consumer && terraform init && terraform apply  # reads base's outputs
```

This is how team stacks decouple: the network team owns network state; the app team reads
its outputs without copying resource ids around.

> For real teams, `base` should use a remote backend (section-06 lab 06), not a local
> file. Here we use a local path for simplicity.
