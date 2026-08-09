# Case Study 01 — ASOS

**Organization:** ASOS · **Industry:** Online fashion retail · **Scale:** Global, peak traffic in the millions of shoppers

## The challenge
A fast-growing online retailer that needed to move off an on-premises estate to a cloud
that could absorb flash-sale traffic spikes, while keeping a single, auditable way to
provision hundreds of environments.

## The Terraform-on-Azure pattern (what this repo teaches)
- Adopted Terraform as the **single source of truth** for infrastructure, replacing ad-hoc
  portal clicks and scripts.
- Built a **modular** catalog (network, identity, data, app) so every team composed the same
  building blocks — the same idea as this repo's `modules/` folder.
- Ran Terraform through **CI/CD pipelines** so every change was reviewed, planned, and
  applied automatically — no manual `apply` in production.
- Used an enterprise **landing zone** (hub/spoke networking, centralized logging, RBAC) as
  the foundation every workload inherits.

## Outcomes this pattern typically delivers (illustrative)
- Faster, repeatable environment provisioning.
- Improved auditability and governance (everything is in version control).
- Ability to scale for peak shopping events.

## Labs to run
- `labs/section-04-modules-and-networking/05-module-vm` and `06` — reusable modules.
- `labs/section-05-operations-and-landing-zones/06-landing-zone-rg` → `12` — the landing zone.
- `labs/section-06-workflows-and-cicd/11-github-actions` — pipeline-driven applies.

## Source / verify
Verified primary source (Microsoft Customer Story): https://www.microsoft.com/en-us/customers/story/718983-asos-retail-and-consumer-goods-azure
Also: https://www.microsoft.com/en-us/customers/story/1731404546482708710-asos-retailer-azure-ai-studio
