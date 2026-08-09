# 01 — Authentication with an App Registration

This lab shows how to authenticate Terraform to Azure using a **service principal** (an
App Registration / Enterprise Application) instead of an interactive login. This is the
foundation for any CI/CD pipeline.

## Steps

1. Create the service principal ( Contributor role on your subscription):

   ```bash
   az ad sp create-for-rbac --name "tf-learn-sp" --role Contributor \
     --scopes "/subscriptions/<SUBSCRIPTION_ID>"
   ```

   The output contains `appId` (client id), `password` (client secret), `tenant` and
   the subscription id.

2. Export the credentials as environment variables:

   ```bash
   export ARM_SUBSCRIPTION_ID="<subscription-id>"
   export ARM_CLIENT_ID="<appId>"
   export ARM_CLIENT_SECRET="<password>"
   export ARM_TENANT_ID="<tenant>"
   ```

3. The `azurerm` provider picks these up automatically — no secrets in the code:

   ```bash
   terraform init
   terraform plan
   ```

## Why bother?

- Reproducible, headless runs in pipelines.
- Least-privilege: scope the SP to a resource group instead of a subscription.
- No interactive `az login` needed on build agents.

## Notes

This lab creates no Azure resources itself; it only demonstrates authentication. The
`data "azurerm_subscription"` block proves the credentials work by reading the current
subscription.
