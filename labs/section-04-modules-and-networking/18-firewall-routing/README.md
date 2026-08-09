# 18 — Azure Firewall — routing traffic

A route table sends the workload subnet's outbound traffic (`0.0.0.0/0`) to the firewall
(`next_hop_type = VirtualAppliance`). Associate the table with the workload subnet.
