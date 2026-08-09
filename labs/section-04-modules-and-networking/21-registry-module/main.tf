# Lab 21 — consume a module from the public Terraform Registry.
#  - source = "Azure/network/azurerm" (namespace/name/provider) with a pinned version.
#  - `terraform init` downloads it; the .terraform.lock.hcl pins it.
# This is how you reuse community-maintained modules instead of writing everything.
# Outputs (vnet_id, subnet_ids) come from the registry module's declared outputs.
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
