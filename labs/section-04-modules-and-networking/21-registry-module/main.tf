module "network" {
  source  = "Azure/network/azurerm"
  version = "5.2.0"

  resource_group_name     = "rg-registry-module"
  resource_group_location = "eastus"
  address_space           = "10.33.0.0/16"
  subnet_prefixes         = ["10.33.1.0/24", "10.33.2.0/24"]
  subnet_names            = ["web", "app"]
  tags = {
    managedby = "terraform"
    section    = "04-registry-module"
  }
}

output "vnet_id"        { value = module.network.vnet_id }
output "subnet_ids"    { value = module.network.subnet_ids }
