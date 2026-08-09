<div align="center">

# 🌐 Terraform on Azure — Essentials

**Learn infrastructure-as-code by doing — 126 hands-on labs, one concept at a time.**

A progressive, original journey through Terraform on Microsoft Azure:
from your first resource group all the way to landing zones and CI/CD.

<br>

[![Terraform](https://img.shields.io/badge/Terraform-%E2%89%A5_1.5-7B42BC?logo=terraform&logoColor=white)](https://developer.hashicorp.com/terraform/)
[![Azure](https://img.shields.io/badge/Microsoft_Azure-0078D4?logo=microsoft-azure&logoColor=white)](https://azure.microsoft.com/)
[![Labs](https://img.shields.io/badge/labs-126-0078D4?style=flat)](docs/lab-index.md)
[![Sections](https://img.shields.io/badge/sections-6-0078D4?style=flat)](#-whats-inside)
[![Modules](https://img.shields.io/badge/reusable%20modules-5-6CC04A?style=flat)](modules/)
[![License: MIT](https://img.shields.io/badge/license-MIT-green?style=flat)](LICENSE)
[![Status](https://img.shields.io/badge/status-learning%20ready-2EA44F?style=flat)](#-how-to-use-this-repo)
</div>

---

> **In a sentence:** clone this repo, run `terraform apply` in any lab folder, and watch
> Azure resources appear. Then `terraform destroy` and move on to the next lab.

> 🆕 **Never used Terraform before?** Read the step-by-step beginner guide first:
> **[docs/how-to-run-a-lab.md](docs/how-to-run-a-lab.md)** — install the tools, run your
> first lab successfully, understand what happened, and clean up so you don't get billed.

## ✨ What makes this repo different

- 🎯 **Progressive** — six sections that build on each other, no giant leaps.
- 🧩 **Self-contained** — every lab folder runs on its own after `terraform init`.
- 🛡️ **Best-practice oriented** — provider pinning, variable validation, outputs,
  sensible naming, remote state, and secrets handled the right way.
- 🆕 **Original** — every file written from scratch. Not copied from any vendor course.
  Same *concepts* you'll find in popular curricula, but our own code.

---

## 📦 What's inside

| | Section | Labs | You'll learn |
|---|---|:---:|---|
| 1️⃣ | [**Foundations**](labs/section-01-foundations/) | 25 | Storage, blobs, references, VNet, subnets, NIC, public IP, NSG, VM, variables, outputs, secrets, data disks + advanced (import, moved, templatefile, cidrsubnet) |
| 2️⃣ | [**Meta-arguments & repetition**](labs/section-02-meta-arguments/) | 21 | `count`, `for_each`, availability sets/zones, Key Vault, data sources, dynamic blocks, provisioners, Bastion |
| 3️⃣ | [**Web apps & databases**](labs/section-03-web-apps-and-databases/) | 22 | App Service & slots, lifecycle, tags, Azure SQL, MySQL, connecting apps to databases, VNet integration + advanced (autoscale, source control, Entra ID, MySQL HA) |
| 4️⃣ | [**Modules & networking**](labs/section-04-modules-and-networking/) | 25 | Local modules, Load Balancer, VMSS w/ autoscale, Traffic Manager, VNet peering, App Gateway, Azure Firewall + advanced (internal LB, path routing, SSL, firewall policy) |
| 5️⃣ | [**Operations & landing zones**](labs/section-05-operations-and-landing-zones/) | 16 | Azure Monitor, metric alerts, Log Analytics, RBAC, resource locks, a full Application Landing Zone + advanced (custom policy, diagnostics, activity alerts, managed identity) |
| 6️⃣ | [**Workflows & CI/CD**](labs/section-06-workflows-and-cicd/) | 13 | Multiple environments, workspaces, Git, remote state in Azure Storage, ACI, AKS, Azure DevOps pipelines + advanced (remote_state, GitHub Actions, terraform test) |

Plus **5 reusable local modules** in [`modules/`](modules/) — `rg-only`, `vnet`, `ip-nic`,
`nsg`, and a full `vm-stack`.

> Full table of every single lab: see [`docs/lab-index.md`](docs/lab-index.md).

---

## 🚀 Quickstart

**1. Install the tools** (one-time)

- [Terraform](https://developer.hashicorp.com/terraform/downloads) ≥ 1.5
- [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli) (`az`)
- [Git](https://git-scm.com/)

**2. Authenticate to Azure**

```bash
az login
az account set --subscription "<your-subscription-id>"
```

**3. Pick any lab and run it**

```bash
cd labs/section-01-foundations/02-storage-account
terraform init      # download providers
terraform plan       # preview the changes
terraform apply      # create the resources (type 'yes')
```

**4. Clean up when you're done** 💰

```bash
terraform destroy
```

> ⚠️ Labs create **real** Azure resources that can incur cost. Always destroy what you
> create. The labs default to the cheapest SKUs (`Standard_B1s`, `Basic`, `B1`).

Want the deeper setup (service principal for automation, VS Code extensions, region
choice)? See [`docs/prerequisites.md`](docs/prerequisites.md).

---

## 🗂 Repository layout

```
terraform-azure-essentials/
├── docs/                      # Concept guides + the learning path + full lab index
│   ├── prerequisites.md
│   ├── learning-path.md
│   ├── lab-index.md
│   └── concepts/              # providers, variables, state, modules
├── labs/
│   ├── section-01-foundations/
│   ├── section-02-meta-arguments/
│   ├── section-03-web-apps-and-databases/
│   ├── section-04-modules-and-networking/
│   ├── section-05-operations-and-landing-zones/
│   └── section-06-workflows-and-cicd/
└── modules/                   # Reusable local modules
```

Each lab folder contains its own `README.md` explaining the concept and exactly how to
run it.

---

## 🧭 How to use this repo

1. **Start at Section 1**, lab 1, and work forward. Each lab assumes the concepts from
   the ones before it.
2. **Read the lab's `README.md` first** — it tells you *what* you're building and *why*.
3. **Run it**, then **modify it**. Change a value, `terraform plan`, and read the diff.
   That feedback loop is where the real learning happens.
4. **Destroy before you leave** a lab so the next one starts clean and your bill stays
   near zero.

Stuck or want the big picture? The concept guides in [`docs/concepts/`](docs/concepts/)
explain the building blocks (providers, variables, state, modules).

---

## 👤 Who this is for

- People learning Terraform who want to *apply* it, not just read about it.
- Azure engineers wanting a hands-on reference for real resource patterns.
- Anyone preparing for Terraform-on-Azure certifications who wants runnable examples.
- Teams onboarding new members to IaC — each lab is a small, reviewable unit.

You should be comfortable in a terminal and know roughly what a cloud resource is. No
prior Terraform knowledge is assumed.

---

## 🔐 A note on secrets & state

This repo is safe to clone and push — by design:

- No real credentials are stored. Secrets live behind `sensitive = true` variables and
  are supplied via `.tfvars` (gitignored) or environment variables.
- State files (`*.tfstate`) are gitignored — they can contain secrets in plaintext.
- The `.gitignore` blocks keys (`.pem`, `id_rsa`), env files, plan files, and Azure
  auth JSON so they never accidentally get committed.

> **Never commit your real `terraform.tfvars` or any private key.** If a secret ever does
> get committed, treat it as compromised: rotate it, then remove it from git history.

---

## 📜 License

[MIT](LICENSE) — use it, fork it, learn from it.

---

<div align="center">

**126 labs · 6 sections · 5 modules · 0 secrets committed.**

Made for learning. Built to be run.

</div>
