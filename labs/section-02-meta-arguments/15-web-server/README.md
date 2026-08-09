# 15 — Web server via Terraform

Deploy a Linux VM and install nginx using the `custom_data` (cloud-init) mechanism — the
Terraform-native, idempotent alternative to a one-off provisioner. The VM is reachable on
port 22 (SSH) and 80 (HTTP).
