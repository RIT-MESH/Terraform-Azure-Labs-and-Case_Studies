# 19 — Variable definition file (tfvars)

`terraform.tfvars` (or `*.auto.tfvars`) supplies variable values without cluttering the
CLI. This lab reuses lab 18's variables and overrides the defaults via a tfvars file.

```bash
terraform plan                      # uses terraform.tfvars
terraform plan -var-file=dev.tfvars # explicit file
```
