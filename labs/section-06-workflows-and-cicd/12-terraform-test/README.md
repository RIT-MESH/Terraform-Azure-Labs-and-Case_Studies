# 12 — `terraform test` (advanced)

Terraform's built-in test framework (`.tftest.hcl`) runs assertions against `plan` and
`apply` without external tools. This lab ships a tiny storage-account config and a test
that asserts the plan contains exactly one storage account with the expected tier.

```bash
terraform init
terraform test
```

`terraform test` runs each `run` block, which can `plan` (fast, no resources) or `apply`
(creates then destroys within the test). Here we use `plan`-only assertions.
