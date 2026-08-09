# 19 — Mini project — App Service virtual network integration

When your database is private (no public access), the web app needs a VNet integration to
reach it. This lab creates a delegated `Microsoft.Web/serverFarms` subnet and wires the
web app to it with `vnet_route_all_enabled = true`.
