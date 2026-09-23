# Section 4 — Modules and networking

Build a reusable **local module** end to end, then tackle the heavier network appliances:
Load Balancer, Virtual Machine Scale Set, Traffic Manager, VNet peering, Application
Gateway and Azure Firewall.

## How to use these labs

Prerequisites:

- **Terraform >= 1.5** (`terraform -version` to check)
- **Azure CLI** and a subscription you can create resource groups in — run `az login`
  once per session; Terraform picks up that login's subscription.
- An **SSH public key** (`~/.ssh/id_ed25519.pub` or similar) for the VM labs.

Typical command flow, run from inside a lab folder:

```bash
cd labs/section-04-modules-and-networking/<lab-folder>
az login                                  # once, before the first lab of the day
cp terraform.tfvars.example terraform.tfvars   # only in labs that need it (fill in your SSH key or IP inputs)
terraform init      # downloads providers + any modules
terraform plan      # preview
terraform apply     # type yes; load balancers/firewalls/app gateways take minutes
terraform output    # grab IPs / DNS names to test in the portal
terraform destroy   # clean up before moving on
```

Notes:

- Labs 01-06 consume the shared local modules in `labs/modules/` — that is the point:
  the root configs are thin callers. Lab 21 switches to a public registry module.
- Some labs are split (setup + implementation, e.g. 14/15, 16-20): the later lab reads
  the earlier lab's `terraform output` values into its `terraform.tfvars`, so run them
  in order.
- Each lab's README lists exactly what it creates, the portal pages to inspect, and the
  concepts/gotchas — read the lab README before its code.

## Labs

1. [Modules — resource group](01-module-resource-group/)
2. [Modules — virtual network](02-module-vnet/)
3. [Modules — public IP & NIC](03-module-ip-nic/)
4. [Modules — network security groups](04-module-nsg/)
5. [Modules — virtual machines](05-module-vm/)
6. [Modules — copy files to server](06-module-copy-files/)
7. [Azure Load Balancer](07-load-balancer/)
8. [Virtual Machine Scale Set](08-vmss/)
9. [Traffic Manager — web apps](09-traffic-manager/)
10. [Traffic Manager — implementation](10-traffic-manager-impl/)
11. [VNet peering — setup](11-vnet-peering-setup/)
12. [VNet peering — machines](12-vnet-peering-machines/)
13. [VNet peering — implementation](13-vnet-peering-impl/)
14. [Application Gateway — VMs](14-app-gateway-vms/)
15. [Application Gateway — implementation](15-app-gateway-impl/)
16. [Azure Firewall — VMs](16-firewall-vms/)
17. [Azure Firewall — deploy](17-firewall-deploy/)
18. [Azure Firewall — routing](18-firewall-routing/)
19. [Azure Firewall — NAT rule](19-firewall-nat-rule/)
20. [Azure Firewall — application rule](20-firewall-app-rule/)
21. [Using a registry module](21-registry-module/)

## Advanced labs

22. [Internal Load Balancer](22-internal-load-balancer/)
23. [Application Gateway — path-based routing](23-app-gateway-path-routing/)
24. [Application Gateway — SSL via Key Vault](24-app-gateway-ssl/)
25. [Azure Firewall — policy-based](25-firewall-policy/)
