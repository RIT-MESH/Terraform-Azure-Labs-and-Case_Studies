# 20 — App Service auto-scale (advanced)

A `B1` plan is fixed-size. This lab puts a web app on an **autoscale-enabled** plan (`P1v3`)
with rules: scale out when CPU > 70%, in when CPU < 30%, between 1 and 3 instances.
`azurerm_monitor_autoscale_setting` is the same resource type used for VMSS — it works on
any scalable target, including App Service plans.
