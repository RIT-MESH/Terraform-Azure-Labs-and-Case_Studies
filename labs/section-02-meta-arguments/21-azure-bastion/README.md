# 21 — Azure Bastion

Bastion gives you RDP/SSH over TLS (port 443) **without** exposing a public IP on the VM.
It needs a dedicated subnet named `AzureBastionSubnet` with a /26 or larger prefix.

This lab deploys a VM with **no public IP** plus a Bastion host, then you connect from the
portal: *Connect → Bastion → username/password*.

> Bastion Standard needs ~10 minutes to deploy. Be patient.
