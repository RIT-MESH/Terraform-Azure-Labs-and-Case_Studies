terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = { source = "hashicorp/azurerm", version = "~> 3.70" }
  }
}

# A registry module needs the azurerm provider configured here.
provider "azurerm" {
  features {}
}
