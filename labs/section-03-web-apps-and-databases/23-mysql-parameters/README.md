# 23 — MySQL Flexible Server — configuration & HA (advanced)

Beyond the basics (lab 15), MySQL Flexible Server lets you tune server parameters and
run zone-redundant high availability. This lab:

- sets `high_availability = ZoneRedundant` (2 instances across zones),
- tunes a server configuration value (`max_connections`) with
  `azurerm_mysql_flexible_server_configuration`,
- enables a maintenance window so patching is predictable.
