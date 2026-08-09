# outputs.tf — values returned to the caller / printed after apply.
output "vnet_id"   { value = azurerm_virtual_network.this.id }
output "vnet_name" { value = azurerm_virtual_network.this.name }
