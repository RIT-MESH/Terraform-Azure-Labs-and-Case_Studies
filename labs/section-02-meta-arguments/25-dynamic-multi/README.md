# 25 — Dynamic blocks at multiple levels (advanced)

Combine two `dynamic` blocks in one resource: an NSG whose **security rules** are
generated from a list, and a NIC whose **ip_configurations** are generated from a list —
all from variables, no code changes to add a rule or an IP config.

Addressing: VNet `172.22.0.0/20`, subnet `172.22.0.0/26`.
