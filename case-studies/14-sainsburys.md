# Case Study 14 — Sainsbury's

**Organization:** Sainsbury's · **Industry:** Retail · **Scale:** Supermarkets + online, ephemeral test envs

## The challenge
Dev teams need many short-lived environments for testing; manual provisioning was slow and
left resources running, inflating cost.

## The Terraform-on-Azure pattern (what this repo teaches)
- **Ephemeral environments** spun up and torn down via pipelines using tfvars per branch.
- **Remote state** in Azure Storage with locking so teams share safely.
- **Autoscale** for web tiers; **resource locks** only on permanent prod.
- Automated `terraform destroy` at the end of each test run.

## Outcomes this pattern typically delivers (illustrative)
- Faster test-environment turnaround.
- Lower spend from automatic teardown.
- Safe concurrent team work via state locking.

## Labs to run
- `labs/section-06-workflows-and-cicd/06-remote-state-storage`.
- `labs/section-06-workflows-and-cicd/11-github-actions`.
- `labs/section-04-modules-and-networking/08-vmss`.

## Source / verify
Publicly reported Azure adoption. Verify at Microsoft Customer Stories
(https://www.microsoft.com/en-us/customerstories — search "Sainsbury's Azure").
