# 04 — Using Git on our local machine

Version your Terraform. This lab has no Terraform of its own — it's the Git workflow:

```bash
git init
git add .
git commit -m "initial Terraform"
git branch feature/networking
git switch feature/networking
# ... make changes ...
git switch main
git merge feature/networking
git tag v1.0
git log --oneline
```

Rules for IaC repos:

- Never commit `terraform.tfstate` (gitignored).
- Never commit secret tfvars (gitignored).
- Review every PR for `plan` output.
- Tag releases so you can roll back.
