# 22 — Conditional resources (advanced feature flags)

`count = var.enabled ? 1 : 0` toggles a resource on/off without an `if` block. This lab
creates a VNet always, but creates the NSG only when `deploy_nsg = true`. Flip the
variable and `terraform plan` shows the NSG being added or removed — the VNet is untouched.

Addressing: VNet `172.19.0.0/20`, subnet `172.19.0.0/26`.
