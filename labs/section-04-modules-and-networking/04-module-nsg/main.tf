terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = { source = "hashicorp/azurerm", version = "~> 3.70" }
  }
}
provider "azurerm" { features {} }

module "network" {
  source = "../../../modules/vnet"

  name            = "vnet-modnsg"
  location        = "eastus"
  address_space   = ["10.13.0.0/16"]
  subnet_prefixes  = ["10.13.1.0/24"]
  subnet_names    = ["web"]
}

module "nsg" {
  source = "../../../modules/nsg"

  name                = "nsg-modnsg"
  location            = "eastus"
  resource_group_name = "rg-vnet-modnsg"
  allowed_ports       = [22, 80, 443]
  subnet_id           = module.network.subnet_ids[0]
}

output "nsg_id" { value = module.nsg.nsg_id }
