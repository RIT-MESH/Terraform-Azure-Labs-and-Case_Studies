# Enterprise case studies

Fifteen real-world, enterprise-scale stories of organizations adopting Terraform on Azure.
Each one is written for learning: the **challenge**, the **Terraform-on-Azure approach**
(mapped to the concepts and labs in this repository), the **reported outcomes**, and the
**labs you should run** to practice the same patterns.

> **Important — how to read these.** These write-ups are **educational summaries based on
> publicly reported cloud-adoption stories**, authored in our own words (no text copied from
> any vendor). Company-specific details are kept at the level that is publicly known; for
> exact figures, SLAs, and quotes, please consult the original **Microsoft Customer
> Stories** (<https://customers.microsoft.com>) and **HashiCorp case studies**
> (<https://www.hashicorp.com/customers>) pages. Outcomes are described qualitatively on
> purpose so we never misrepresent a company's internal numbers.

## Index

| # | Organization | Industry | Theme in this repo |
|---|---|---|---|
| 01 | [ASOS](01-asos.md) | Online fashion retail | Landing zones, modules, CI/CD |
| 02 | [Mercedes-Benz](02-mercedes-benz.md) | Automotive / connected mobility | Multi-region, networking, AKS |
| 03 | [Carlsberg](03-carlsberg.md) | Beverages | Enterprise landing zone, governance |
| 04 | [Tetra Pak](04-tetra-pak.md) | Packaging / manufacturing | Hybrid connectivity, policy |
| 05 | [Repsol](05-repsol.md) | Energy | Data platform, modules at scale |
| 06 | [Co-op](06-co-op.md) | Retail / consumer co-op | Multi-subscription governance |
| 07 | [3M](07-3m.md) | Diversified manufacturing | Standardized modules, drift control |
| 08 | [Nationwide Building Society](08-nationwide.md) | Financial services | Regulated landing zone, RBAC |
| 09 | [L'Oréal](09-loreal.md) | Consumer goods / beauty | Global apps, Traffic Manager |
| 10 | [Carnival Corporation](10-carnival.md) | Cruise / hospitality | Scale-out + autoscale |
| 11 | [Mars](11-mars.md) | Consumer goods / petcare | Multi-environment workspaces |
| 12 | [Manulife](12-manulife.md) | Financial services | Policy-as-code, audit |
| 13 | [Fujitsu](13-fujitsu.md) | IT services | Internal platform / modules |
| 14 | [Sainsbury's](14-sainsburys.md) | Retail | Ephemeral envs, remote state |
| 15 | [PepsiCo](15-pepsico.md) | Consumer goods | Big-data infra, VMSS, AKS |

## How to use these with the labs

Each case study ends with a **"Labs to run"** section pointing at specific folders in
`labs/`. Run those labs, then imagine the same pattern multiplied across hundreds of
subscriptions — that is the enterprise version of what you just built.
