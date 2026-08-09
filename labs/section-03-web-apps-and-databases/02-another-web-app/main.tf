data "azurerm_service_plan" "this" {
  name                = var.existing_plan_name
  resource_group_name = var.existing_rg_name
}

resource "azurerm_linux_web_app" "second" {
  name                = "app-second-${substr(md5(timestamp()), 0, 8)}"
  location            = data.azurerm_service_plan.this.location
  resource_group_name = var.existing_rg_name
  service_plan_id     = data.azurerm_service_plan.this.id

  site_config {
    application_stack {
      node_version = "18-lts"
    }
  }
}

output "default_hostname" { value = azurerm_linux_web_app.second.default_hostname }
