# 16 — Managed identity + least-privilege RBAC (advanced)

A VM with a **system-assigned managed identity** can authenticate to Azure without any
stored secret. This lab gives a Linux VM an identity, then grants it **only** the
`Storage Blob Data Reader` role on one storage account — least privilege in action. From
inside the VM you can read blobs using Azure RBAC (no SAS, no key).

Addressing: VNet `172.27.0.0/20`; subnet `172.27.0.0/26`.
