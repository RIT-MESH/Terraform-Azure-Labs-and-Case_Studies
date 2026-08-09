# 13 — Virtual Machine Scale Set

A VMSS deploys identical VMs that auto-scale. This lab uses a Linux VMSS behind a
public Standard Load Balancer with autoscale rules: scale out above 75% CPU, in below
25%. Cloud-init installs nginx so the scale set serves HTTP.
