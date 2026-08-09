# Learning path

The repository is organised into six progressive sections. Each section is a folder
under `labs/` and contains a numbered sequence of self-contained labs.

## Section 1 — Foundations

Build the core muscle: authenticate, create storage, then virtual networks, subnets,
network interfaces, public IPs, security groups, a virtual machine, and learn how to
parameterise configurations with variables, locals, outputs and tfvars.

## Section 2 — Meta-arguments and repetition

Scale one resource into many using `count` and `for_each`. Add resilience with
availability sets and zones. Protect secrets in Key Vault. Use dynamic blocks,
provisioners and Azure Bastion.

## Section 3 — Web apps and databases

Deploy Azure App Service and its slots, apply lifecycle rules and tags, then provision
Azure SQL Database and a MySQL server, and connect an app to its database.

## Section 4 — Modules and networking

Build a reusable local module end to end (resource group → VNet → VM). Add a Load
Balancer, a Virtual Machine Scale Set, Traffic Manager, VNet peering, Application
Gateway and Azure Firewall.

## Section 5 — Operations and landing zones

Observability with Azure Monitor and Log Analytics, plus RBAC role assignments and
resource locks. Finish with a multi-resource Application Landing Zone mini-project.

## Section 6 — Workflows and CI/CD

Manage multiple environments with workspaces and tfvars, store state remotely in Azure
Storage, version with Git, and deploy Azure Container Instances, AKS, and an Azure
DevOps release pipeline.

---

## Quick concept index

| Concept | First introduced |
|---|---|
| Provider & resource blocks | section-01 / 02 |
| Locals & expressions | section-01 / 07 |
| Input variables & tfvars | section-01 / 18 |
| Outputs | section-01 / 14 |
| `depends_on` | section-01 / 05 |
| `count` | section-02 / 01 |
| `for_each` | section-02 / 03 |
| Dynamic blocks | section-02 / 16 |
| Provisioners | section-02 / 20 |
| Modules (local) | section-04 / 01 |
| Remote state | section-06 / 06 |
| Workspaces | section-06 / 03 |

---

See [docs/lab-index.md](lab-index.md) for the full table of every lab and the reusable modules.

---

## Advanced concepts (added per section)

Each section now ends with 4 advanced labs. A few highlights:

| Concept | Lab |
|---|---|
| `import` block / CLI import | 01-22 |
| `moved` & `removed` blocks | 01-23, 06-13 |
| `templatefile()` | 01-24 |
| `cidrsubnet` / `cidrhost` | 01-25 |
| Conditional resources (feature flags) | 02-22 |
| `flatten()` nested→flat | 02-23 |
| `for_each` over data sources | 02-24 |
| Multi-level `dynamic` blocks | 02-25 |
| App Service autoscale | 03-20 |
| App Service source control (Git) | 03-21 |
| SQL Entra ID admin | 03-22 |
| MySQL config + zone-redundant HA | 03-23 |
| Internal Load Balancer | 04-22 |
| App Gateway path-based routing | 04-23 |
| App Gateway SSL via Key Vault | 04-24 |
| Azure Firewall policy | 04-25 |
| Custom policy definition | 05-13 |
| Diagnostic settings | 05-14 |
| Activity log alert + webhook | 05-15 |
| Managed identity + least-privilege RBAC | 05-16 |
| `terraform_remote_state` | 06-10 |
| GitHub Actions CI | 06-11 |
| `terraform test` | 06-12 |
