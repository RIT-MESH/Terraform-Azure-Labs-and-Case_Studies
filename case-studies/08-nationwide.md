# Case Study 08 — Nationwide Building Society

**Organization:** Nationwide Building Society · **Industry:** Financial services · **Scale:** UK building society, regulated

## The challenge
A regulated financial institution needs a **secure, auditable** cloud platform where every
change is reviewable and least-privilege access is enforced.

## The Terraform-on-Azure approach
- A regulated **landing zone** with segregated networks and centralized logging.
- Strict **RBAC** via role assignments, and **resource locks** on production data.
- **Key Vault** for secrets — never in code or state-on-laptops.
- All applies through approved pipelines; no direct production access.

## Reported outcomes (qualitative)
- Audit-friendly change history (everything in version control).
- Least-privilege access enforced as code.
- Secrets managed centrally.

## Labs to run
- `labs/section-02-meta-arguments/13-key-vault`.
- `labs/section-05-operations-and-landing-zones/04-role-assignments`, `05-resource-locks`,
  `11-landing-zone-keyvault`.

## Source / verify
Verified primary source (Microsoft Customer Story): https://www.microsoft.com/en-us/customers/story/23308-nationwide-building-society-microsoft-commercial-marketplace
