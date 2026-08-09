# 38 — Azure DevOps release pipelines

This lab is a **pipeline definition**, not Terraform resources. Below is an example Azure
DevOps YAML pipeline that validates, plans, and applies the section-01 storage lab.

Save it as `azure-pipelines.yml` at the repo root, create a service connection named
`azure-arm` (an ARM service principal), and run the pipeline.

## Variables / secret handling

Store `ARM_CLIENT_SECRET` as a pipeline secret variable. The `terraform plan` step
publishes a plan artifact; the `apply` stage waits on approval, then applies.
