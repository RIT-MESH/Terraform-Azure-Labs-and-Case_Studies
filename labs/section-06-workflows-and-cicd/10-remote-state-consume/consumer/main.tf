terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = { source = "hashicorp/azurerm", version = "~> 3.70" }
  }
}
provider "azurerm" { features {} }

# Read outputs from the base stack's local state.
data "terraform_remote_state" "base" {
  backend = "local"
  config = {
    path = "${path.module}/../base/terraform.tfstate"
  }
}

resource "azurerm_storage_container" "from_base" {
  name                  = "consumed"
  storage_account_name  = data.terraform_remote_state.base.outputs.storage_account_name
  container_access_type = "private"
}

output "consumed_in" { value = data.terraform_remote_state.base.outputs.storage_account_name }
