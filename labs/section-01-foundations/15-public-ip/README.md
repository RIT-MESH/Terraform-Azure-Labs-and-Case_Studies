# 15 — Public IP Address

`azurerm_public_ip` gives a resource a routable IP. This lab provisions a static Standard
public IP and reads the assigned address as an output. Compare the `allocation_method`
and `sku` options (`Basic` vs `Standard`, `Static` vs `Dynamic`).
