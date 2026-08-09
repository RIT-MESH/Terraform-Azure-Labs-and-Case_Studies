# 13 — VNet peering — implementation

Add bidirectional peering with `azurerm_virtual_network_peering`. Both directions are
needed (hub→spoke and spoke→hub). Enable `allow_virtual_network_access` so traffic flows;
`allow_forwarded_traffic` lets the hub route for the spoke.
