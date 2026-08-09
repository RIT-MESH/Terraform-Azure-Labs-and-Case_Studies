# 16 — Network Security Group

An NSG is a stateful firewall attached to a subnet or NIC. This lab creates an NSG that
allows inbound RDP (3389) and HTTPS (443) and denies everything else by default, then
associates it with the web subnet.

> Assignment: tighten the rule to your home IP only via `source_address_prefix`.
