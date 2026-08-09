# 10 — Types — Map

A `map` is a key→value collection. Maps are ideal when you address things by a
meaningful key rather than a positional index. Here each subnet has a key (`web`,
`app`, `data`) carrying its role.

Concepts:

- `map(object({...}))` type
- `for_each` over a map
- `each.key` / `each.value`
