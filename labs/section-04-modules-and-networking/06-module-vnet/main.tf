terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = { source = "hashicorp/azurerm", version = "~> 3.70" }
  }
}
provider "azurerm" { features {} }

module "network" {
  source = "../../../modules/vnet"

  name                = "vnet-modvnet"
  location            = "eastus"
  address_space       = ["10.11.0.0/16"]
  subnet_prefixes     = ["10.11.1.0/24", "10.11.2.0/24"]
  subnet_names        = ["web", "app"]
}

output "vnet_id"      { value = module.network.vnet_id }
output "subnet_ids"   { value = module.network.subnet_ids }
