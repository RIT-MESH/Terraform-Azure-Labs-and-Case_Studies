# 13 — Network interface

A VM needs a NIC. This lab creates the VNet + web subnet, then an
`azurerm_network_interface` with one `ip_configuration` bound to that subnet. A NIC can
carry several IP configurations (this one has just one, private, dynamic).

> Assignment: add a second `ip_configuration` with a static private IP.
