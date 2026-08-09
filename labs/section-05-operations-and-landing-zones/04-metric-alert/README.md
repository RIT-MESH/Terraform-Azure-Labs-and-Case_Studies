# 04 — Metric alert via Terraform

`azurerm_monitor_metric_alert` watches a metric and fires an action group. This lab
alerts when the VM's CPU goes above 80% for 5 minutes. Point `resource_id` at the VM
from lab 03 (or pass as a variable).
