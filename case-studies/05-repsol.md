# Case Study 05 — Repsol

**Organization:** Repsol · **Industry:** Energy · **Scale:** Data-intensive exploration and analytics

## The challenge
Stand up a **data platform** that many teams can consume, with shared governance and the
ability to scale storage/compute on demand.

## The Terraform-on-Azure pattern (what this repo teaches)
- Terraform **modules** provision the data landing zone (resource groups, VNet, storage,
  data stores) consistently per team.
- **Multiple environments** (dev/test/prod) driven by tfvars/workspaces.
- **Remote state** in Azure Storage for team collaboration and locking.
- Networking via hub/spoke with private endpoints for data services.

## Outcomes this pattern typically delivers (illustrative)
- Faster delivery of data environments to teams.
- Shared governance with per-team isolation.
- Reproducible environments.

## Labs to run
- `labs/section-06-workflows-and-cicd/02-multiple-environments` and `03-workspaces-dev`.
- `labs/section-06-workflows-and-cicd/06-remote-state-storage`.

## Source / verify
Verify at Microsoft Customer Stories (https://www.microsoft.com/en-us/customerstories — search "Repsol Azure") and HashiCorp customers (https://www.hashicorp.com/customers).
