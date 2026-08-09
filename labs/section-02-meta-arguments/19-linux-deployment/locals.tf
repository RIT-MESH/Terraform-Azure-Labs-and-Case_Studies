# Lab 19 — deploy the restructured VM (lab 18) end to end with public IP + NSG.
terraform {
  required_version = ">= 1.5.0"
  required_providers { azurerm = { source = "hashicorp/azurerm", version = "~> 3.70" } }
}
provider "azurerm" { features {} }

locals {
  ssh_pubkey = fileexists("id_rsa.pub") ? file("id_rsa.pub") : "ssh-rsa REPLACE_ME"
  rg         = "rg-linux-deploy"
}
