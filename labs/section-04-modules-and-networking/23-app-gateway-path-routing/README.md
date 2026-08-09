# 23 — Application Gateway — path-based routing (advanced)

Lab 15 used one backend pool. Here a single App Gateway routes by **URL path**: requests
to `/images/*` go to one backend pool, `/video/*` to another, and everything else to a
default pool. This is the building block for hosting several services behind one domain.

Addressing: VNet `172.24.0.0/20`; gateway subnet `172.24.0.0/26`; backend subnet
`172.24.0.64/26`. Backend VMs run nginx (no real services needed for the demo).
