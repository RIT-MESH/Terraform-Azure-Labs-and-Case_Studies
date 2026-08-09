# 22 — Internal Load Balancer (advanced)

Lab 07 made a *public* LB. Here the frontend IP is **private** (inside a VNet), so the
load-balanced service is only reachable from inside the network — the classic pattern for
fronting an internal API behind a public gateway/firewall. Two backend VMs run nginx.

Addressing: VNet `172.23.0.0/20`; backend subnet `172.23.0.0/26`; frontend subnet
`172.23.0.64/26` (the LB's private frontend IP lives here).
