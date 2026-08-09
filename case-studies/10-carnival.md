# Case Study 10 — Carnival Corporation

**Organization:** Carnival Corporation · **Industry:** Cruise / hospitality · **Scale:** Seasonal, demand spikes

## The challenge
Booking and onboard systems face big seasonal demand spikes; capacity must scale up and
down automatically to control cost.

## The Terraform-on-Azure approach
- **Virtual Machine Scale Sets** with autoscale rules (CPU-based).
- **Application Gateway** for Layer-7 traffic to backend pools.
- **Load Balancer** for tier distribution; autoscale settings managed as code.
- Workspaces/tfvars for seasonal vs. off-season capacity baselines.

## Reported outcomes (qualitative)
- Automatic scaling for peak demand.
- Controlled cost by scaling down off-peak.
- Consistent, repeatable networking stack.

## Labs to run
- `labs/section-04-modules-and-networking/08-vmss`.
- `labs/section-04-modules-and-networking/07-load-balancer`.
- `labs/section-04-modules-and-networking/15-app-gateway-impl`.

## Source / verify
Verify at Microsoft Customer Stories (https://www.microsoft.com/en-us/customerstories — search "Carnival Corporation Azure").
