terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = { source = "hashicorp/azurerm", version = "~> 3.70" }
  }
}
provider "azurerm" { features {} }

module "rg" {
  source = "../../../modules/rg-only"

  name     = "rg-modulerg"
  location = "eastus"
}

output "rg_id"   { value = module.rg.id }
output "rg_name" { value = module.rg.name }
