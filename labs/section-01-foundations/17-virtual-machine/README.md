# 17 — Azure Virtual Machine

Bring it all together: VNet + subnet + public IP + NIC + NSG + VM. This is the canonical
"first VM" stack. We use a small Windows Server 2022 image on `Standard_B1s`.

> NB: `admin_password` is marked `sensitive`. Provide it via `terraform.tfvars` (gitignored)
> or a `-var` flag — never commit it.
