# Case Study 04 — Tetra Pak

**Organization:** Tetra Pak · **Industry:** Packaging / manufacturing · **Scale:** Global manufacturing with on-prem systems

## The challenge
Connect factory and on-premises systems to Azure workloads **securely** while keeping
strict network controls and consistent governance.

## The Terraform-on-Azure approach
- **Hybrid networking**: VNet peering / hub-spoke with on-prem connectivity, managed as code.
- **Azure Policy** to enforce tagging and allowed regions/SKUs across subscriptions.
- Terraform **modules** for the network, identity, and data layers.
- Central **diagnostic settings** to ship logs to a Log Analytics workspace.

## Reported outcomes (qualitative)
- Secure hybrid connectivity without manual network config.
- Policy-as-code preventing non-compliant resources.
- Centralized observability.

## Labs to run
- `labs/section-04-modules-and-networking/11..13` (VNet peering).
- `labs/section-05-operations-and-landing-zones/12-landing-zone-policy` and `14-diagnostic-settings`.

## Source / verify
Verified source: https://www.casestudies.com/company/microsoft-azure/case-study/tetra-pak-enhances-its-industry-advantage-and-sustainability-goals-with-azure-iot
Also: Microsoft Customer Stories (https://www.microsoft.com/en-us/customerstories — search "Tetra Pak Azure").
