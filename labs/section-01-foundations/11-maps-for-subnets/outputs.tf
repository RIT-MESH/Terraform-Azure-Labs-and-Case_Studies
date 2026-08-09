output "subnet_count" { value = length(var.subnets) }
output "subnet_names" { value = keys(azurerm_subnet.this) }
