terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.70"
    }
  }
}

provider "azurerm" {
  features {}

  # Credentials are read from ARM_* environment variables by default.
  # No secrets are hard-coded here on purpose.
}

# Prove the credentials work by reading the current subscription.
data "azurerm_subscription" "current" {}

output "subscription_id" {
  value       = data.azurerm_subscription.current.subscription_id
  description = "The subscription Terraform authenticated against."
}

output "display_name" {
  value = data.azurerm_subscription.current.display_name
}
