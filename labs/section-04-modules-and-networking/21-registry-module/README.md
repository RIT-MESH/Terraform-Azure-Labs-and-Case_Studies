# 21 — Using a module from the Terraform Registry

Public modules live at registry.terraform.io. This lab uses the official
`hashicorp/subnet/cidr` ... actually we use the popular **`Azure/network/azurerm`** module
to create a VNet + subnets without writing the resources ourselves.

```hcl
module "network" {
  source  = "Azure/network/azurerm"
  version = "5.2.0"
  ...
}
```

Run `terraform init` — Terraform downloads the module and the lock file pins it.
