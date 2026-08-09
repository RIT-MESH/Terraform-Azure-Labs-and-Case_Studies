variable "rules" {
  type = list(object({
    name     = string
    priority = number
    port     = number
  }))
  default = [
    { name = "Allow-HTTP",  priority = 200, port = 80 },
    { name = "Allow-HTTPS", priority = 210, port = 443 },
  ]
}

resource "azurerm_resource_group" "this" {
  name     = "rg-dynamic"
  location = "eastus"
}

resource "azurerm_network_security_group" "this" {
  name                = "nsg-dynamic"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name

  dynamic "security_rule" {
    for_each = var.rules
    content {
      name                       = security_rule.value.name
      priority                   = security_rule.value.priority
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = tostring(security_rule.value.port)
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
  }
}

output "rule_names" {
  value = [for r in var.rules : r.name]
}
