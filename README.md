# Terraform on Azure — Essentials

A hands-on, original learning repository that walks through **infrastructure-as-code with Terraform on Microsoft Azure**, from first principles to production-style landing zones and CI/CD.

> All code in this repository is **original work** written for educational purposes. It is **not** derived from any specific vendor course. Concepts covered overlap with popular Terraform-on-Azure curricula (resources, meta-arguments, modules, networking, databases, operations, CI/CD) but every file was authored fresh.

## Why this repository?

- **Progressive** — six sections, each building on the previous one.
- **Self-contained** — every lab folder is independently runnable (after `terraform init`).
- **Best-practice oriented** — pinning, variable validation, outputs, sensible naming, remote state guidance.
- **Original** — no copy-paste from third-party materials.

## Repository layout

```
terraform-azure-essentials/
├── docs/                 # Concept guides and the learning path
├── labs/
│   ├── section-01-foundations/          # Storage, VNet, NIC, IP, NSG, VM, vars, secrets
│   ├── section-02-meta-arguments/        # count, for_each, availability, Key Vault, Bastion
│   ├── section-03-web-apps-and-databases/# App Service, slots, SQL DB, MySQL
│   ├── section-04-modules-and-networking/# Modules, LB, VMSS, Traffic Manager, peering, FW
│   ├── section-05-operations-landing-zones/ # Monitor, Log Analytics, RBAC, locks, landing zone
│   └── section-06-workflows-and-cicd/    # Workspaces, remote state, ACI, AKS, DevOps
└── modules/              # Reusable local modules used by several labs
```

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/downloads) >= 1.5
- [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli) (`az`)
- An Azure subscription. Authenticate with:

  ```bash
  az login
  az account set --subscription "<your-subscription-id>"
  ```

See [docs/prerequisites.md](docs/prerequisites.md) for details, including the recommended **service principal** approach used in the first lab.

## How to run a lab

Each lab is self-contained. From a lab folder:

```bash
terraform init
terraform plan
terraform apply
```

Clean up when done:

```bash
terraform destroy
```

> ⚠️ Running labs creates real Azure resources that may incur cost. Always `terraform destroy` when finished.

## Learning path

Follow the sections in order, or jump to a topic using the table in [docs/learning-path.md](docs/learning-path.md).

## License

MIT — see [LICENSE](LICENSE).
