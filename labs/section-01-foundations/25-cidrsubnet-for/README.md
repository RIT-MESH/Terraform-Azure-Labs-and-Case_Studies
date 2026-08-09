# 25 — `cidrsubnet` / `cidrhost` & `for` (advanced addressing)

Stop hard-coding CIDRs. Derive them from a base with the `cidrsubnet(prefix, newbits, netnum)`
function, and compute host addresses with `cidrhost`. This lab carves four `/26` subnets
out of a single `/20` VNet using a `for` expression, then outputs the first host of each.

Addressing: base VNet `172.18.0.0/20`, subnets `172.18.0.0/26`, `.64/26`, `.128/26`, `.192/26`.
