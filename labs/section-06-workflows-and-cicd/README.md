# Section 6 — Workflows and CI/CD

Manage multiple environments, store state remotely, version with Git, and deploy
containers (Azure Container Instances, AKS) through Azure DevOps pipelines.

## How to use these labs

Work through the labs in order — each builds on the habits of the previous one
(plan → review → apply, branching, remote state, then pipeline automation).

Prerequisites:

- **Terraform >= 1.5** (lab 13's `removed` blocks need 1.7+) — check with
  `terraform version`.
- **Azure CLI** installed and **`az login`** run — the azurerm provider uses
  your CLI session by default.
- **Git** (labs 04, 11) and, for lab 08, **kubectl** for the AKS follow-up.

The typical command flow for almost every lab:

```bash
cd <lab-folder>
terraform init       # download providers / wire up the backend (once per folder)
terraform plan       # review the diff — always
terraform apply      # create the resources
terraform output     # read declared outputs
terraform destroy    # clean up when you're done
```

Labs 02–03 add `-var-file=...` and workspace commands; lab 12 runs `terraform test`
instead of `apply`; labs 09 and 11 don't create Azure resources themselves — they
are pipeline definitions you install in a repo. Labs 06 and 10 have subfolders
(`bootstrap/` + `app/`, `base/` + `consumer/`) that run in the documented order.

## Labs

1. [Inspecting the initial code base](01-inspect-codebase/)
2. [Deploying to multiple environments](02-multiple-environments/)
3. [Terraform workspaces — dev](03-workspaces-dev/)
4. [Using Git locally](04-git-local/)
5. [Making changes to code](05-making-changes/)
6. [Azure Storage for the state file](06-remote-state-storage/)
7. [Azure Container Instance](07-container-instance/)
8. [Azure Kubernetes Service](08-aks/)
9. [Azure DevOps release pipelines](09-devops-release-pipelines/)

## Advanced labs

10. [`terraform_remote_state` — consume another stack](10-remote-state-consume/)
11. [GitHub Actions CI](11-github-actions/)
12. [`terraform test` framework](12-terraform-test/)
13. [`moved` and `removed` blocks](13-moved-removed/)