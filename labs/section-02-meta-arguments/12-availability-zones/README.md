# 12 — Availability Zones

Availability Zones are physically separate datacenters with independent power. Pinning a
VM to a zone (`zone = 1`) gives a 99.99% SLA. This lab creates three VMs, one per zone,
by zipping a list of zones with `count`.
