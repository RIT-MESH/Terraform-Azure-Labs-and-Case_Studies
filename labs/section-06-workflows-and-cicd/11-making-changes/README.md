# 11 — Making changes to our code

Iterate safely: change code → `terraform plan` → review the diff → `apply`. This lab
takes the storage account and adds a container + blob. Practice the change workflow:

```bash
terraform plan          # shows +container and +blob
terraform apply
```

Then tweak the blob content and `plan` again — watch the in-place update.
