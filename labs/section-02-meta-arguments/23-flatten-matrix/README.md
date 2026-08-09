# 23 — `flatten()` — nested structures into a resource list (advanced)

`flatten()` turns a nested list-of-lists into one flat list, which you then iterate with
`for_each`. Here a matrix of **region × tier** is expanded into a flat list of subnets —
one per (region, tier) pair — each created as its own resource in the matching regional
VNet.

Addressing: `region-a` VNet `172.20.0.0/20`, `region-b` VNet `172.21.0.0/20`; subnets `/26`.
