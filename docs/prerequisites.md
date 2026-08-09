# Prerequisites

## 1. Install the tools

| Tool | Why | Minimum version |
|---|---|---|
| Terraform | The IaC engine | 1.5+ |
| Azure CLI | Authenticate and inspect Azure | 2.50+ |
| Git | Version the code | 2.30+ |

Verify:

```bash
terraform version
az version
git --version
```

## 2. Authenticate to Azure

### Option A — interactive login (simplest, good for learning)

```bash
az login
az account set --subscription "<subscription-id>"
```

Then let the `azurerm` provider read your credentials from the CLI session:

```hcl
provider "azurerm" {
  features {}
}
```

### Option B — service principal (recommended for automation)

Create a service principal and feed its credentials to Terraform via environment
variables (see [section-01 / 01-authentication-app-object](../labs/section-01-foundations/01-authentication-app-object/)):

```bash
az ad sp create-for-rbac --name "tf-learn-sp" --role Contributor \
  --scopes "/subscriptions/<subscription-id>"
```

Export the returned values:

```bash
export ARM_CLIENT_ID="<appId>"
export ARM_CLIENT_SECRET="<password>"
export ARM_SUBSCRIPTION_ID="<subscription-id>"
export ARM_TENANT_ID="<tenant>"
```

## 3. Pick a region

Choose a region close to you and use it consistently across labs:

```bash
az account list-locations --query "[].name" -o tsv | head
```

## 4. Cost safety

- Always run `terraform destroy` when you finish a lab.
- Use the smallest SKUs provided in each lab (e.g. `Standard_B1s`).
- Set up billing alerts in the Azure portal.

## 5. Recommended VS Code extensions

- HashiCorp Terraform (`hashicorp.terraform`)
- Azure Terraform (`ms-azuretools.vscode-azureterraform`)
- Azure Account (`ms-vscode.azure-account`)
