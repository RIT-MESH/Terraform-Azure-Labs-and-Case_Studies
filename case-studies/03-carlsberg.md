# Case Study 03 — Carlsberg

**Organization:** Carlsberg · **Industry:** Beverages · **Scale:** Multi-market enterprise

## The challenge
Modernize a fragmented IT estate into a governed Azure platform where business units can
self-serve applications **without** violating compliance.

## The Terraform-on-Azure approach
- Rolled out an enterprise **landing zone** with subscription vending for each business unit.
- Centralized **logging and policy** so every subscription inherits the same guardrails.
- Used Terraform **modules** so a new market is a tfvars change, not a new codebase.
- RBAC and resource **locks** to protect critical data stores.

## Reported outcomes (qualitative)
- Faster onboarding of new markets/applications.
- Consistent compliance posture across the estate.
- Reduced configuration drift.

## Labs to run
- `labs/section-05-operations-and-landing-zones/06-landing-zone-rg` through `12-landing-zone-policy`.
- `labs/section-05-operations-and-landing-zones/05-resource-locks`.

## Source / verify
Verify at Microsoft Customer Stories (https://www.microsoft.com/en-us/customerstories — search "Carlsberg Azure") and HashiCorp customers (https://www.hashicorp.com/customers).
