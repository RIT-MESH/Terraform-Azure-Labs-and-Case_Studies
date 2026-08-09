terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = { source = "hashicorp/azurerm", version = "~> 3.70" }
  }
}
provider "azurerm" { features {} }

module "network" {
  source = "../../../modules/vnet"

  name            = "vnet-modip"
  location        = "eastus"
  address_space   = ["10.12.0.0/16"]
  subnet_prefixes  = ["10.12.1.0/24"]
  subnet_names    = ["web"]
}

module "nic" {
  source = "../../../modules/ip-nic"

  name                = "nic-modip"
  location            = "eastus"
  resource_group_name = "rg-vnet-modip"
  subnet_id           = module.network.subnet_ids[0]
}

output "nic_id"    { value = module.nic.nic_id }
output "public_ip" { value = module.nic.public_ip }
