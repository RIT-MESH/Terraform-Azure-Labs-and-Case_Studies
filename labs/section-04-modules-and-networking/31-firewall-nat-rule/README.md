# 31 — Azure Firewall — NAT rule

A DNAT rule forwards inbound port 22 on the firewall's public IP to the workload VM's
port 22, so you can SSH to the workload *through* the firewall without a public IP on
the VM.
