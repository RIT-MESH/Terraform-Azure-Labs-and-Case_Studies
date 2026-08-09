# 03 — The `for_each` meta-argument

`for_each` creates one resource per **element of a set or map**. Each copy is addressed
by its key (`resource.name["key"]`). Prefer `for_each` over `count` when copies differ
in their configuration and are best addressed by a meaningful key.

This lab creates three containers named after a set of stages: `dev`, `stg`, `prod`.
