terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = { source = "hashicorp/azurerm", version = "~> 3.70" }
  }
}
provider "azurerm" { features {} }

variable "webhook_url" {
  type      = string
  sensitive = true
}

data "azurerm_subscription" "current" {}

resource "azurerm_resource_group" "this" {
  name     = "rg-activity-alert"
  location = "eastus"
}

resource "azurerm_monitor_action_group" "this" {
  name                = "ag-rg-delete"
  resource_group_name = azurerm_resource_group.this.name
  short_name          = "rgdel"

  webhook_receiver {
    name        = "notify-webhook"
    service_uri = var.webhook_url
  }
}

resource "azurerm_monitor_activity_log_alert" "rg_delete" {
  name                = "alert-rg-delete"
  resource_group_name = azurerm_resource_group.this.name
  location            = "global"
  scopes              = [data.azurerm_subscription.current.id]

  criteria {
    category       = "Administrative"
    operation_name = "Microsoft.Resources/subscriptions/resourceGroups/delete"
    level          = "Critical"
  }

  action {
    action_group_id = azurerm_monitor_action_group.this.id
  }

  description = "Fires when a resource group is deleted in the subscription."
}

output "action_group_id" { value = azurerm_monitor_action_group.this.id }
