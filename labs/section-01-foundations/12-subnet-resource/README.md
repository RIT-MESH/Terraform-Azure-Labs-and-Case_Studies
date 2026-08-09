# 12 — Subnet as a separate resource

Lab 06 defined subnets inline. This lab uses `azurerm_subnet` as its own resource, which
is far more flexible: you can add NSGs, delegations, service endpoints and peering per
subnet without rewriting the VNet.
