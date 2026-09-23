# Section 2 — Meta-arguments and repetition

Real infrastructure has many similar resources. This section shows the two repetition
meta-arguments — `count` and `for_each` — then adds resilience (availability sets/zones),
secrets (Key Vault), flexibility (dynamic blocks), post-creation actions (provisioners),
and secure access (Azure Bastion).

## How to use these labs

**Prerequisites**

- **Terraform >= 1.5** — `terraform -version` to check.
- **Azure CLI** (`az`) installed and signed in: `az login` (each lab talks to your
  subscription; labs 13 and 14 additionally use the signed-in identity).
- A subscription where you can create/destroy resource groups. All resources in these
  labs are cheap lab sizes (`Standard_B1s`) — run `terraform destroy` when done.

**Typical command flow** (inside a lab folder):

```bash
cd 01-count-meta-argument          # pick a lab folder
terraform init                     # download providers (once per lab)
terraform plan                     # preview exactly what will be created
terraform apply                    # create it (type "yes" to confirm)
terraform output container_names   # read results
terraform destroy                  # delete everything the lab created
```

Pass inputs with `-var=name=value` or a `terraform.tfvars` file when a lab needs them
(SSH keys, passwords, existing resource-group names). Each lab's README lists its
variables and what to click in the Azure portal.

## Labs

1. [The `count` meta-argument](01-count-meta-argument/)
2. [Multiple storage containers](02-multiple-containers/)
3. [The `for_each` meta-argument](03-for-each-meta-argument/)
4. [`for_each` over blobs](04-for-each-blobs/)
5. [Multiple subnets](05-multiple-subnets/)
6. [Multiple network interfaces](06-multiple-nics/) *(assignment)*
7. [Multiple public IPs](07-multiple-public-ips/)
8. [`for_each` + variables](08-for-each-variables/)
9. [Network Security Groups](09-network-security-groups/)
10. [Multiple virtual machines](10-multiple-vms/)
11. [Availability Sets](11-availability-sets/)
12. [Availability Zones](12-availability-zones/)
13. [Azure Key Vault](13-key-vault/)
14. [Data sources](14-data-sources/)
15. [Web server via Terraform](15-web-server/)
16. [Dynamic blocks](16-dynamic-blocks/)
17. [Linux machine — read a local file](17-linux-read-file/)
18. [Linux machine — restructure](18-linux-restructure/)
19. [Linux machine — deployment](19-linux-deployment/)
20. [Provisioners](20-provisioners/)
21. [Azure Bastion](21-azure-bastion/)

## Advanced labs

22. [Conditional resources (feature flags)](22-conditional-resources/)
23. [`flatten()` — nested structures into a list](23-flatten-matrix/)
24. [`for_each` over a data source](24-for-data-sources/)
25. [Dynamic blocks at multiple levels](25-dynamic-multi/)
