# Case Study 06 — Co-op

**Organization:** Co-op (UK) · **Industry:** Retail / consumer co-operative · **Scale:** Multi-subscription estate

## The challenge
Manage many subscriptions across food retail and funeral/insurance businesses with a
consistent, secure foundation — without a central bottleneck team doing manual work.

## The Terraform-on-Azure approach
- **Multi-subscription governance**: a hub subscription with shared services; spoke
  subscriptions per business unit, all defined in code.
- Terraform **modules** as the contract between platform and product teams.
- **Azure Policy** and RBAC applied at scale via code.
- Pipelines that plan before apply, with approvals for production.

## Reported outcomes (qualitative)
- Self-service within guardrails.
- Consistent security baseline across business units.
- Reduced manual platform toil.

## Labs to run
- `labs/section-05-operations-and-landing-zones/06..12` (landing zone).
- `labs/section-05-operations-and-landing-zones/04-role-assignments`.

## Source / verify
Verify at Microsoft Customer Stories (https://www.microsoft.com/en-us/customerstories — search "Co-op Azure") and HashiCorp customers (https://www.hashicorp.com/customers).
