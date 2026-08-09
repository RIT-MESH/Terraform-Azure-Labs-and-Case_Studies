# 05 — Locking resources with Terraform

A management lock (`CanNotDelete` / `ReadOnly`) protects resources from accidental
deletion. This lab puts a `CanNotDelete` lock on a storage account so `terraform destroy`
(or a portal click) refuses to remove it.
