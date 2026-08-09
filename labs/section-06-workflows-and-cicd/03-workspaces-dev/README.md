# 03 — Terraform workspaces — dev environment

Workspaces let one configuration manage several state files (e.g. dev, stg, prod). The
`terraform.workspace` value picks names/tiers per workspace.

```bash
terraform workspace new dev
terraform workspace new prod
terraform workspace select dev
terraform apply
terraform workspace select prod
terraform apply
```

> Workspaces share the same backend, so they're best for *environments of the same shape*.
> For fundamentally different environments, prefer separate directories/backends.
