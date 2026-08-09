# Case Study 12 — Manulife

**Organization:** Manulife · **Industry:** Financial services / insurance · **Scale:** Multi-region, regulated

## The challenge
A regulated insurer needs strong guardrails: only approved resources, in approved
regions, with full audit of who changed what.

## The Terraform-on-Azure pattern (what this repo teaches)
- **Policy-as-code**: built-in + custom Azure Policy definitions assigned at scale.
- Terraform modules that already comply with policy, so teams can't drift even if they try.
- Central **Log Analytics** + diagnostic settings for audit.
- RBAC role assignments scoped per subscription.

## Outcomes this pattern typically delivers (illustrative)
- Non-compliant resources blocked at deployment.
- Comprehensive audit trail of changes.
- Compliance posture defined in version control.

## Labs to run
- `labs/section-05-operations-and-landing-zones/12-landing-zone-policy` and `13-custom-policy-definition`.
- `labs/section-05-operations-and-landing-zones/14-diagnostic-settings`.
- `labs/section-05-operations-and-landing-zones/04-role-assignments`.

## Source / verify
Publicly reported Azure adoption. Verify at Microsoft Customer Stories
(https://www.microsoft.com/en-us/customerstories — search "Manulife Azure").
