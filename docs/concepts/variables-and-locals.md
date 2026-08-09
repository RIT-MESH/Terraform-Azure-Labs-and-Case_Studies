# Variables and locals

Both store values, but they have different roles.

## Input variables

Inputs make a configuration reusable. Declare them, then pass values via tfvars, the
CLI (`-var`), or environment variables (`TF_VAR_*`).

```hcl
variable "location" {
  type        = string
  description = "Azure region for all resources"
  default     = "eastus"

  validation {
    condition     = length(var.location) > 0
    error_message = "Location cannot be empty."
  }
}
```

Use it: `var.location`.

## Locals

Locals derive values from inputs (and other data) inside a configuration. They keep
repeated expressions DRY and readable.

```hcl
locals {
  short_region = lower(replace(var.location, " ", ""))
  rg_name      = "rg-${var.project}-${local.short_region}"
}
```

Use them: `local.rg_name`.

## Rule of thumb

- **Inputs** change per environment → use `variable`.
- **Derived/intermediate** values → use `locals`.
- **Returned values** for downstream consumers → use `output`.
