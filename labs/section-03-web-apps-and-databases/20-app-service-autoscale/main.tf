# Lab 20 — App Service auto-scale.
# A B1 plan is fixed. We use a Premium V3 plan (P1v3) which supports autoscale, with
# rules: scale out > 70% CPU, scale in < 30%, between 1 and 3 instances. The same
# azurerm_monitor_autoscale_setting resource works on VMSS too.
terraform {
  required_version = ">= 1.5.0"
  required_providers { azurerm = { source = "hashicorp/azurerm", version = "~> 3.70" } }
}
provider "azurerm" { features {} }

resource "azurerm_resource_group" "this" {
  name     = "rg-appscale"
  location = "eastus"
}

resource "azurerm_service_plan" "this" {
  name                = "asp-appscale"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  os_type             = "Linux"
  sku_name            = "P1v3"   # Premium V3 enables autoscale
}

resource "azurerm_linux_web_app" "this" {
  name                = "app-appscale-${substr(md5(timestamp()), 0, 8)}"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  service_plan_id     = azurerm_service_plan.this.id
  site_config {
    application_stack { node_version = "18-lts" }
  }
}

resource "azurerm_monitor_autoscale_setting" "plan" {
  name                = "autoscale-asp"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  target_resource_id  = azurerm_service_plan.this.id   # what we scale

  profile {
    name = "default"
    capacity {
      default = 1   # starting instance count
      minimum = 1
      maximum = 3
    }
    # Scale OUT: average CPU > 70% → add 1 instance.
    rule {
      metric_trigger {
        metric_name        = "CpuPercentage"
        metric_resource_id = azurerm_service_plan.this.id
        time_grain         = "PT1M"      # ISO 8601: 1 minute
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "GreaterThan"
        threshold          = 70
      }
      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = 1
        cooldown  = "PT1M"
      }
    }
    # Scale IN: average CPU < 30% → remove 1 instance.
    rule {
      metric_trigger {
        metric_name        = "CpuPercentage"
        metric_resource_id = azurerm_service_plan.this.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "LessThan"
        threshold          = 30
      }
      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = 1
        cooldown  = "PT1M"
      }
    }
  }
}

output "hostname" { value = azurerm_linux_web_app.this.default_hostname }
