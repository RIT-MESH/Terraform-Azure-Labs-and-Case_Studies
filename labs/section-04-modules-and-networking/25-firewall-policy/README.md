# 25 — Azure Firewall — policy-based (advanced)

Labs 17-20 attached rule collections **directly** to the firewall (classic). The modern
approach is a **Firewall Policy** (`azurerm_firewall_policy`) holding rule collection
groups, which the firewall references with `firewall_policy_id`. Policies are versioned,
can be shared across firewalls, and are the only way to use premium features / Intrusion
Detection.

This lab deploys a firewall that points at a policy containing:
- a DNAT rule (inbound SSH to a workload),
- a network rule (allow outbound to a service),
- an application rule (allow a set of FQDNs).

Addressing: VNet `172.26.0.0/20`; `AzureFirewallSubnet` `172.26.0.0/26`;
workload subnet `172.26.0.64/26`.
