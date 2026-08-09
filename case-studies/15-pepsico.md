# Case Study 15 — PepsiCo

**Organization:** PepsiCo · **Industry:** Consumer goods · **Scale:** Big-data analytics + global apps

## The challenge
A big-data and analytics platform serving many global teams, needing elastic compute and
container orchestration alongside classic VM workloads.

## The Terraform-on-Azure pattern (what this repo teaches)
- **VMSS** for elastic batch processing with autoscale.
- **AKS** for containerized analytics services.
- Terraform **modules** for the data-landing zone; per-team instances via tfvars.
- **Diagnostic settings** + Log Analytics for platform observability.

## Outcomes this pattern typically delivers (illustrative)
- Elastic compute scaling with demand.
- Mixed VM + container workloads managed consistently.
- Reproducible data environments.

## Labs to run
- `labs/section-04-modules-and-networking/08-vmss`.
- `labs/section-06-workflows-and-cicd/08-aks`.
- `labs/section-05-operations-and-landing-zones/14-diagnostic-settings`.

## Source / verify
Publicly reported Azure adoption. Verify at Microsoft Customer Stories
(https://www.microsoft.com/en-us/customerstories — search "PepsiCo Azure").
