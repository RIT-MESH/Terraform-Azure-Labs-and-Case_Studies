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
