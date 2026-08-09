# Case Study 02 — Mercedes-Benz

**Organization:** Mercedes-Benz · **Industry:** Automotive / connected mobility · **Scale:** Connected-vehicle platform across regions

## The challenge
A connected-mobility platform that must be **highly available across regions**, with
strict networking controls between vehicle-ingest, processing, and back-office tiers.

## The Terraform-on-Azure pattern (what this repo teaches)
- Multi-region deployment with **Traffic Manager** fronting regional stamps.
- **Hub-and-spoke networking** with Azure Firewall as the central egress/inspection point.
- **AKS** clusters for containerized services, provisioned with Terraform.
- Reusable **modules** so each region is a parameterized copy of the same code.

## Outcomes this pattern typically delivers (illustrative)
- Global routing with failover for the connected-vehicle platform.
- Centralized, policy-controlled egress via Azure Firewall.
- Repeatable multi-region rollout.

## Labs to run
- `labs/section-04-modules-and-networking/09-traffic-manager` and `10` — multi-region routing.
- `labs/section-04-modules-and-networking/25-firewall-policy` — central firewall.
- `labs/section-06-workflows-and-cicd/08-aks` — Kubernetes clusters.

## Source / verify
Verify at Microsoft Customer Stories (https://www.microsoft.com/en-us/customerstories — search "Mercedes-Benz Azure") and HashiCorp customers (https://www.hashicorp.com/customers).
