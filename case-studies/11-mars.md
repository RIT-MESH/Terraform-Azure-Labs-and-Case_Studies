# Case Study 11 — Mars

**Organization:** Mars · **Industry:** Consumer goods / petcare · **Scale:** Global brands, many business segments

## The challenge
Multiple segments (petcare, confectionery, food) each needing their own environments while
sharing a common, governed platform.

## The Terraform-on-Azure approach
- **Workspaces** and per-segment tfvars to keep one codebase but separate state per segment.
- A **shared services** hub (networking, identity) consumed by every segment.
- **Tagging** enforced for cost attribution by segment and region.
- Pipelines that apply per workspace with approvals.

## Reported outcomes (qualitative)
- Segment isolation without code duplication.
- Clear cost attribution.
- Consistent platform services across segments.

## Labs to run
- `labs/section-06-workflows-and-cicd/03-workspaces-dev`.
- `labs/section-06-workflows-and-cicd/02-multiple-environments`.
- `labs/section-03-web-apps-and-databases/04-resource-tags`.

## Source / verify
Publicly reported Azure adoption. Verify at Microsoft Customer Stories
(https://www.microsoft.com/en-us/customerstories — search "Mars Azure") and HashiCorp
customers (https://www.hashicorp.com/customers).
