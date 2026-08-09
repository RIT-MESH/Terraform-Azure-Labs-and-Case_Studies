# 03 — The `lifecycle` meta-argument

`lifecycle {}` changes how Terraform treats a resource over time:

- `create_before_destroy` — build the new version first, then tear down the old.
- `prevent_destroy` — refuse to destroy (safety guard for prod databases).
- `ignore_changes` — leave chosen attributes to drift (e.g. tags set by another tool).

This lab sets `create_before_destroy` on a storage container and ignores an externally
managed tag.
