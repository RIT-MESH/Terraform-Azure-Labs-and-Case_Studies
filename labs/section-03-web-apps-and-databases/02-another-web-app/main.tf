# Lab 02 (assignment) — deploy a SECOND web app reusing an existing service plan.
# We look up the plan with a `data` block (it must already exist), then create a
# new app on it. One plan can host many apps.
terraform {
  required_version = ">= 1.5.0"
  required_providers { azurerm = { source = "hashicorp/azurerm", version = "~> 3.70" } }
}
provider "azurerm" { features {} }

variable "existing_plan_name" { type = string, default = "asp-webapp" }
variable "existing_rg_name"   { type = string, default = "rg-webapp" }

# READ the existing plan (created in lab 01). We don't manage it here.
data "azurerm_service_plan" "this" {
  name                = var.existing_plan_name
  resource_group_name = var.existing_rg_name
}

# A second app on the same plan.
resource "azurerm_linux_web_app" "second" {
  name                = "app-second-${substr(md5(timestamp()), 0, 8)}"
  location            = data.azurerm_service_plan.this.location
  resource_group_name = var.existing_rg_name
  service_plan_id     = data.azurerm_service_plan.this.id

  site_config {
    application_stack { node_version = "18-lts" }
  }
}

output "default_hostname" { value = azurerm_linux_web_app.second.default_hostname }
