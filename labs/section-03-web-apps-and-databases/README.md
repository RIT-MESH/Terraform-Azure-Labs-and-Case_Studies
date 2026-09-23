# Section 3 — Web apps and databases

Move from VMs to managed platforms. Deploy Azure App Service and its deployment slots,
apply lifecycle rules and resource tags, then provision an Azure SQL Database (with
firewall rules) and a MySQL server, and finally wire a web app to its database.

## How to use these labs

Prerequisites (once, on your machine):

- **Terraform >= 1.5** — check with `terraform -version`
- **Azure CLI** — check with `az --version`
- **Sign in to Azure** — run `az login` before the first `terraform apply` in a
  session; Terraform uses that identity to create resources. If you have more
  than one subscription, pick one with `az account set --subscription "<name>"`.

Typical flow for every lab (run from inside the lab folder):

```bash
cd 01-web-app          # pick the lab
terraform init         # first time only: download providers
terraform plan         # preview what will be created/changed
terraform apply        # create it (type "yes" to confirm)
terraform output       # print values such as the site URL
terraform destroy      # clean up and stop paying for the lab
```

Labs marked *(assignment)* are self-checks: try them before reading the solution
in `main.tf`. Some labs need a `terraform.tfvars` (see the `terraform.tfvars.example`
file in the lab folder — copy it and fill in a real password or your client IP),
and lab 11 authors a `schema.sql` that lab 13 runs manually.

## Labs

1. [Azure Web App](01-web-app/)
2. [Deploying another web app](02-another-web-app/) *(assignment)*
3. [The `lifecycle` meta-argument](03-lifecycle/)
4. [Resource tags](04-resource-tags/)
5. [Deployment slots — create](05-deployment-slots-create/)
6. [Deployment slots — swap](06-deployment-slots-swap/)
7. [App Service logs](07-app-service-logs/)
8. [Azure SQL Database](08-sql-database/)
9. [SQL Database — firewall rules](09-sql-firewall-rules/)
10. [Change the SQL DTU model](10-change-sql-dtu/) *(assignment)*
11. [Deploying another SQL Database — prepare](11-another-sql-prepare/)
12. [Deploying another SQL Database — deploy](12-another-sql-deploy/)
13. [Adding data to an Azure SQL database](13-sql-add-data/)
14. [Connecting a web app to SQL](14-web-app-to-sql/)
15. [Mini project — MySQL server](15-mysql-server/)
16. [Mini project — configure MySQL](16-mysql-configure/)
18. [Mini project — deploy the web app](18-web-app-deploy/)
19. [Mini project — VNet integration](19-web-app-vnet-integration/)

## Advanced labs

20. [App Service auto-scale](20-app-service-autoscale/)
21. [App Service source control (Git deploy)](21-app-service-source-control/)
22. [Azure SQL with Entra ID admin](22-sql-entra-admin/)
23. [MySQL — configuration & high availability](23-mysql-parameters/)
