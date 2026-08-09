# 13 — Azure Key Vault via Terraform

Key Vault stores secrets, keys and certificates. This lab creates a vault, a secret, and
grants the current user get/list permissions using a `data` block for the current
principal.

> Vault names are globally unique, 3–24 chars, alphanumerics + hyphens only.
