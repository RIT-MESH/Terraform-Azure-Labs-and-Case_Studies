# 13 — `moved` and `removed` blocks (advanced refactoring)

Two refactoring primitives:

- `moved {}` — change a resource's address **without** recreating it (see also lab 23 in
  section 1).
- `removed {}` — drop a resource from Terraform's management **without destroying** it in
  Azure (it stays, now unmanaged). Useful when you want Terraform to stop owning
  something but keep it running.

This lab creates a storage account and demonstrates both blocks. `removed` here targets
a placeholder address so the first apply is a no-op; the README walks through the real
two-step refactor workflow.
