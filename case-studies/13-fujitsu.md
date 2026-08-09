# Case Study 13 — Fujitsu

**Organization:** Fujitsu · **Industry:** IT services · **Scale:** Internal platform + customer deliveries

## The challenge
Fujitsu runs its own internal cloud platform and delivers Azure solutions to customers —
both need a reusable, opinionated set of building blocks.

## The Terraform-on-Azure approach
- A **module catalog** (network, identity, landing zone) used internally and offered to
  customers.
- Standardized **landing zones** delivered per engagement from the same code.
- Remote state and CI for both internal and customer projects.
- Documentation-as-code so each module ships with usage examples (much like this repo).

## Reported outcomes (qualitative)
- Faster delivery across engagements via reusable modules.
- Consistency between internal and customer environments.
- Lower onboarding effort for new teams.

## Labs to run
- `labs/section-04-modules-and-networking/01-module-resource-group` through `06-module-copy-files`.
- `labs/section-06-workflows-and-cicd/06-remote-state-storage`.

## Source / verify
Publicly reported Azure + Terraform usage. Verify at HashiCorp customers
(https://www.hashicorp.com/customers) and Microsoft Customer Stories
(https://www.microsoft.com/en-us/customerstories — search "Fujitsu Azure").
