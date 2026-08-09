# 14 — Diagnostic settings (advanced)

`azurerm_monitor_diagnostic_setting` streams a resource's logs and metrics to a Log
Analytics workspace, a storage account, or Event Hub. This lab sends a storage account's
`blobServices` logs to **both** a Log Analytics workspace (query) and a storage container
(long-term archive) — a common compliance pattern.

Addressing: none (storage + workspace).
