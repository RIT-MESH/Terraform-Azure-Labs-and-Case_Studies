terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = { source = "hashicorp/azurerm", version = "~> 3.70" }
  }

  backend "azurerm" {
    # Fill via `terraform init -backend-config=...` (see README).
    resource_group_name  = "rg-tfstate"
    storage_account_name = "sttfstate<suffix>"
    container_name       = "tfstate"
    key                 = "app.tfstate"
  }
}

provider "azurerm" { features {} }

resource "azurerm_resource_group" "app" {
  name     = "rg-remote-state-app"
  location = "eastus"
}

output "rg_name" { value = azurerm_resource_group.app.name }
