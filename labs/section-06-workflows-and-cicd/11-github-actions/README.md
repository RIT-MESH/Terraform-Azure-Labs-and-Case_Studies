# 11 — GitHub Actions CI (advanced)

A workflow that runs on every PR and on push to `main`:

1. `terraform fmt -check` — reject unformatted code.
2. `terraform init` + `terraform validate`.
3. `terraform plan` on PRs (posts the plan back as a comment via `hashicorp/setup-terraform`).
4. `terraform apply` automatically on push to `main`.

Secrets (`ARM_*`) are stored as GitHub repo secrets. The workflow targets one example lab;
copy and adjust `working-directory` per stack.

> Drop the generated file at the **repo root** as `.github/workflows/terraform.yml` to
> activate it.
