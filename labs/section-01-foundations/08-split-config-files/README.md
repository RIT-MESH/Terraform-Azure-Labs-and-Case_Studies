# 08 — Split configuration files

Real configs grow. Split them by concern:

- `terraform.tf` — versions & provider
- `locals.tf` — derived values
- `main.tf` — resources
- `outputs.tf` — outputs

Terraform merges every `*.tf` file in a directory into one logical configuration, so the
order does not matter. This lab is the **same VNet** as lab 07, just split across files —
the pattern every later lab follows.
