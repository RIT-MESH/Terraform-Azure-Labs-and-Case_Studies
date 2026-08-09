# 09 — SQL Database — firewall rules

By default, nothing can reach your SQL logical server. Add firewall rules:
- one for your client IP (so you can connect from SSMS / Azure Data Studio)
- one for Azure services (`0.0.0.0`–`0.0.0.0`) so App Service can reach it
