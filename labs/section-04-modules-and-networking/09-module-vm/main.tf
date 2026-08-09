terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = { source = "hashicorp/azurerm", version = "~> 3.70" }
  }
}
provider "azurerm" { features {} }

variable "admin_ssh_key" { type = string, sensitive = true }

module "stack" {
  source = "../../../modules/vm-stack"

  name_prefix        = "modvm"
  location           = "eastus"
  admin_ssh_key      = var.admin_ssh_key
  vnet_address_space = ["10.14.0.0/16"]
  subnet_prefix      = "10.14.1.0/24"
  tags               = { project = "section-04", managedby = "terraform" }
}

output "public_ip" { value = module.stack.public_ip }
output "vm_name"   { value = module.stack.vm_name }
