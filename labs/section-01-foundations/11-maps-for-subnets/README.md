# 11 — Maps for subnets (assignment)

Self-check assignment: parameterise subnets as a **variable** typed as
`map(object({...}))` so the same module can deploy different subnet layouts without code
changes.

Try it: open `terraform.tfvars` and change the subnet map, then `terraform plan` to see
the diff before applying.
