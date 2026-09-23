# Section 5 — Operations and landing zones

Observability and governance: Azure Monitor metric alerts, Log Analytics workspaces,
RBAC role assignments, and resource locks — then a multi-resource **Application Landing
Zone** mini-project that ties them together.

## What is a "landing zone"?

A **landing zone** is the pre-built, standardized environment a team "lands" their
application into. Instead of every project inventing its own networking, logging and
permissions, the platform provides a consistent set of building blocks up front:

- **Resource groups** split by concern (network / data / security) so permissions,
  locks and cost reporting can be scoped per concern (lab 06).
- **Networking** in the classic *hub-and-spoke* shape: shared services in a hub VNet,
  workloads in isolated spoke VNets connected by peering (lab 07).
- **Central logging**: one Log Analytics workspace every resource streams diagnostics
  into, plus an archive store (labs 03, 08, 14).
- **Storage / database / Key Vault** as standardized, hardened services for the
  app tier (labs 09–11).
- **Governance**: Azure Policy assignments that refuse non-compliant resources
  (labs 12–13), RBAC role assignments instead of shared keys (labs 04, 16), and
  management locks against accidental deletion (lab 05).

In short: a landing zone is the "empty but ready" scaffolding — Terraform is how you
build and re-create that scaffolding reliably.

## How to use these labs

Prerequisites:

- **Terraform >= 1.5** (`terraform -version` to check).
- **Azure CLI** installed and signed in with `az login` — every lab uses your az cli
  credentials as its Azure identity.
- Labs that need values (an SSH key, a webhook URL, a workspace ID) ship a
  `terraform.tfvars.example`; copy it to `terraform.tfvars` in that lab's folder and
  fill it in.

Typical command flow (run inside the lab folder):

```bash
cd 01-monitor-infra            # one lab folder at a time
cp terraform.tfvars.example terraform.tfvars   # only where the lab needs it
terraform init                 # download the providers
terraform plan                 # preview what will be created
terraform apply                # create it
terraform output               # read exported values (IDs, names) other labs need
terraform destroy              # clean up when done
```

Labs 06–12 form a loose landing-zone series but each lab is self-contained (it
recreates the resources it needs); only lab 10 depends on lab 08's workspace ID,
and lab 02 on lab 01's VM id.

## Labs

1. [Azure Monitor — infrastructure](01-monitor-infra/)
2. [Metric alert via Terraform](02-metric-alert/)
3. [Log Analytics workspace](03-log-analytics/)
4. [Role assignments via Terraform](04-role-assignments/)
5. [Locking resources with Terraform](05-resource-locks/)
6. [Landing Zone — resource groups](06-landing-zone-rg/)
7. [Landing Zone — virtual network](07-landing-zone-vnet/)
8. [Landing Zone — logging](08-landing-zone-logging/)
9. [Landing Zone — storage](09-landing-zone-storage/)
10. [Landing Zone — database](10-landing-zone-database/)
11. [Landing Zone — Key Vault](11-landing-zone-keyvault/)
12. [Landing Zone — Azure Policy](12-landing-zone-policy/)

## Advanced labs

13. [Custom policy definition + assignment](13-custom-policy-definition/)
14. [Diagnostic settings](14-diagnostic-settings/)
15. [Activity log alert + webhook](15-activity-log-alert/)
16. [Managed identity + least-privilege RBAC](16-managed-identity-rbac/)
