# 06 — Deployment slots — swap

Swapping is a runtime action (Azure CLI), not a Terraform resource. After lab 05, run:

```bash
az webapp deployment slot swap \
  --name <app-name> --resource-group rg-slots --slot staging --target-slot production
```

Roll back with `--target-slot production --action swap` reverted, or just swap again.
