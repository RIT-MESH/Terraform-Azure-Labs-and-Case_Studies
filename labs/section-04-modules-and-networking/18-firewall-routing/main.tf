# Lab 18 — route workload traffic THROUGH the Azure Firewall.
#  - azurerm_route_table with a route: 0.0.0.0/0 → next_hop_type = VirtualAppliance,
#    next_hop_in_ip_address = the firewall's private IP (from lab 17).
# Associate this table with the workload subnet → all its outbound traffic goes via
# the firewall (which then applies its NAT/network/application rules).
variable "firewall_private_ip" { type = string }

resource "azurerm_resource_group" "this" {
  name     = "rg-fw-routing"
  location = "eastus"
}

resource "azurerm_route_table" "this" {
  name                = "rt-fw"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name

  route {
    name           = "to-firewall"
    address_prefix = "0.0.0.0/0"
    next_hop_type  = "VirtualAppliance"
    next_hop_in_ip_address = var.firewall_private_ip
  }
}

output "route_table_id" { value = azurerm_route_table.this.id }
