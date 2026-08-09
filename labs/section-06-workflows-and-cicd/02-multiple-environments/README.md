# 02 — Deploying to multiple environments

Drive environment differences purely through tfvars. One configuration, two variable
files (`dev.tfvars`, `prod.tfvars`):

```bash
terraform apply -var-file=dev.tfvars
terraform apply -var-file=prod.tfvars
```

Each file sets its own resource-group name, region, and tags.
