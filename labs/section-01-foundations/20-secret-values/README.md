# 20 — Passing secret values

Three ways to pass a secret:

1. **tfvars** (gitignored) — simplest; fine for learning.
2. **Environment variable** — `TF_VAR_admin_password=...`.
3. **`sensitive = true` variable** — masks the value in plan/apply output.

This lab builds a small VM using all three ideas. Never commit `terraform.tfvars` for
secrets — it's listed in `.gitignore` by default.
