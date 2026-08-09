# Lab 02 — a metric alert + action group.
#  - azurerm_monitor_action_group: WHO to notify (email receiver here).
#  - azurerm_monitor_metric_alert: a rule on a metric (VM Percentage CPU > 80% for 5m).
#    scopes = the VM resource id. When the rule fires, it triggers the action group.
# Point var.vm_resource_id at a VM (e.g. the one from lab 01).
variable "vm_resource_id" { type = string }
variable "admin_email" { type = string }

resource "azurerm_resource_group" "this" {
  name     = "rg-alert"
  location = "eastus"
}

resource "azurerm_monitor_action_group" "this" {
  name                = "ag-cpu-alert"
  resource_group_name = azurerm_resource_group.this.name
  short_name          = "cpualert"

  email_receiver {
    name          = "oncall"
    email_address = var.admin_email
  }
}

resource "azurerm_monitor_metric_alert" "cpu" {
  name                = "alert-cpu-high"
  resource_group_name = azurerm_resource_group.this.name
  scopes              = [var.vm_resource_id]
  severity            = 2

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "Percentage CPU"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 80
  }

  window_size = "PT5M"

  action {
    action_group_id = azurerm_monitor_action_group.this.id
  }
}

output "action_group_id" { value = azurerm_monitor_action_group.this.id }
