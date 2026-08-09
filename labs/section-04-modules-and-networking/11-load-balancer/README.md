# 11 — Azure Load Balancer

A public Standard Load Balancer distributes port 80 traffic across two backend VMs.
Pieces:

- `azurerm_public_ip` for the LB frontend
- `azurerm_lb` (Standard, public)
- `azurerm_lb_backend_address_pool` holding the NICs
- `azurerm_lb_rule` (port 80 → 80)
- `azurerm_lb_probe` (HTTP health probe)

The two VMs run nginx via cloud-init.
