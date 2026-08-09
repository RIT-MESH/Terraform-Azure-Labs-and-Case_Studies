# Lab index

A complete, runnable index of every lab in the repository.

## Section 1 — Foundations (`labs/section-01-foundations/`)

| # | Lab | Concepts |
|---|---|---|
| 01 | authentication-app-object | service principal, `ARM_*` env auth, `data.azurerm_subscription` |
| 02 | storage-account | first resource, random suffix naming |
| 03 | upload-blob | storage container, block blob (`source_content`) |
| 04 | named-value-references | resource / local / variable references |
| 05 | depends-on | explicit ordering when no data reference exists |
| 06 | virtual-network | VNet with inline subnets |
| 07 | local-values | `locals`, `merge()` tags |
| 08 | split-config-files | splitting into multiple `*.tf` files |
| 09 | types-list | `list(string)`, `for` expressions |
| 10 | types-map | `map(object)`, `for_each` over a map |
| 11 | maps-for-subnets | `map(object)` variable, tfvars-driven subnets |
| 12 | subnet-resource | `azurerm_subnet` as a separate resource |
| 13 | network-interface | NIC with `ip_configuration` |
| 14 | output-values | `output`, `sensitive` keys |
| 15 | public-ip | static Standard public IP |
| 16 | network-security-group | NSG + subnet association, security rules |
| 17 | virtual-machine | full Windows VM stack |
| 18 | input-variables | `variable` with validation |
| 19 | variable-definition-file | `terraform.tfvars` |
| 20 | secret-values | `sensitive`, `TF_VAR_*`, tfvars secrets |
| 21 | data-disk | managed disk + VM attachment |

## Section 2 — Meta-arguments (`labs/section-02-meta-arguments/`)

| # | Lab | Concepts |
|---|---|---|
| 01 | count-meta-argument | `count`, `count.index` |
| 02 | multiple-containers | `count` from a variable |
| 03 | for-each-meta-argument | `for_each` over `toset` |
| 04 | for-each-blobs | `for_each` over a map of blobs |
| 05 | multiple-subnets | `for_each` subnet map |
| 06 | multiple-nics | assignment — NICs per tier |
| 07 | multiple-public-ips | `count` + `format()` |
| 08 | for-each-variables | typed map variable + filtered NSGs |
| 09 | network-security-groups | per-tier NSG + association |
| 10 | multiple-vms | `count` VMs with matching NICs |
| 11 | availability-sets | fault/update domains |
| 12 | availability-zones | zone-pinned VMs |
| 13 | key-vault | Key Vault, access policy, secret |
| 14 | data-sources | `data` block reads existing resource |
| 15 | web-server | cloud-init nginx via `custom_data` |
| 16 | dynamic-blocks | `dynamic` from a list of rules |
| 17 | linux-read-file | `file()`, `fileexists()` |
| 18 | linux-restructure | split files: network.tf, vm.tf, outputs.tf |
| 19 | linux-deployment | deployable VM with public IP + NSG |
| 20 | provisioners | `remote-exec` over SSH (last resort) |
| 21 | azure-bastion | Bastion + private VM, `AzureBastionSubnet` |

## Section 3 — Web apps and databases (`labs/section-03-web-apps-and-databases/`)

| # | Lab | Concepts |
|---|---|---|
| 01 | web-app | service plan + Linux web app |
| 02 | another-web-app | reuse a plan via data source |
| 03 | lifecycle | `create_before_destroy`, `ignore_changes` |
| 04 | resource-tags | common tags via `locals` |
| 05 | deployment-slots-create | web app + staging slot |
| 06 | deployment-slots-swap | runtime swap via Azure CLI |
| 07 | app-service-logs | `logs {}` block, blob storage logging |
| 08 | sql-database | logical server + database |
| 09 | sql-firewall-rules | client + Azure service firewall rules |
| 10 | change-sql-dtu | SKU as a variable |
| 11 | another-sql-prepare | authoring T-SQL schema |
| 12 | another-sql-deploy | two databases on one server |
| 13 | sql-add-data | running sqlcmd for migrations |
| 14 | web-app-to-sql | connection string in app settings |
| 15 | mysql-server | MySQL Flexible Server |
| 16 | mysql-configure | MySQL database + client firewall |
| 18 | web-app-deploy | app + MySQL + connection string |
| 19 | web-app-vnet-integration | delegated subnet, regional VNet integration |

## Section 4 — Modules and networking (`labs/section-04-modules-and-networking/`)

| # | Lab | Concepts |
|---|---|---|
| 05 | module-resource-group | first local module |
| 06 | module-vnet | module with multiple subnets |
| 07 | module-ip-nic | module consuming upstream resource id |
| 08 | module-nsg | `dynamic` rules in a module |
| 09 | module-vm | full `vm-stack` module |
| 10 | module-copy-files | `custom_data` cloud-init |
| 11 | load-balancer | public Standard LB, backend pool, probe, rule |
| 13 | vmss | VMSS behind LB with autoscale rules |
| 17 | traffic-manager | performance routing across regions |
| 18 | traffic-manager-impl | priority routing, failover |
| 19 | vnet-peering-setup | two VNets in different regions |
| 20 | vnet-peering-machines | VMs in each VNet |
| 21 | vnet-peering-impl | bidirectional peering |
| 25 | app-gateway-vms | backend VMs for App Gateway |
| 26 | app-gateway-impl | App Gateway v2, listener, routing rule |
| 28 | firewall-vms | hub + workload VM |
| 29 | firewall-deploy | Azure Firewall + public IP |
| 30 | firewall-routing | route table → VirtualAppliance |
| 31 | firewall-nat-rule | DNAT to a workload VM |
| 32 | firewall-app-rule | L7 FQDN allow rules |
| 33 | registry-module | consuming a public registry module |

## Section 5 — Operations and landing zones (`labs/section-05-operations-and-landing-zones/`)

| # | Lab | Concepts |
|---|---|---|
| 03 | monitor-infra | VM to be monitored |
| 04 | metric-alert | metric alert + action group |
| 05 | log-analytics | workspace + diagnostic setting |
| 07 | role-assignments | RBAC via `azurerm_role_assignment` |
| 08 | resource-locks | `CanNotDelete` management lock |
| 10 | landing-zone-rg | multiple resource groups |
| 11 | landing-zone-vnet | hub + spoke VNets + peering |
| 12 | landing-zone-logging | central Log Analytics + archive storage |
| 13 | landing-zone-storage | app storage with TLS 1.2 |
| 14 | landing-zone-database | SQL server + diagnostic setting |
| 15 | landing-zone-keyvault | Key Vault with purge protection |
| 16 | landing-zone-policy | built-in policy assignment |

## Section 6 — Workflows and CI/CD (`labs/section-06-workflows-and-cicd/`)

| # | Lab | Concepts |
|---|---|---|
| 02 | inspect-codebase | `terraform plan` / `terraform graph` |
| 03 | multiple-environments | dev/prod tfvars |
| 05 | workspaces-dev | `terraform.workspace`-driven config |
| 09 | git-local | Git workflow for IaC |
| 11 | making-changes | change → plan → apply loop |
| 16 | remote-state-storage | Azure backend bootstrap + app config |
| 30 | container-instance | Azure Container Instance |
| 32 | aks | AKS cluster with system pool |
| 38 | devops-release-pipelines | Azure Pipelines YAML (plan → apply) |

## Reusable modules (`modules/`)

| Module | Used by | Description |
|---|---|---|
| `rg-only` | 04-05 | single resource group |
| `vnet` | 04-06, 04-07, 04-08 | RG + VNet + subnets |
| `ip-nic` | 04-07 | public IP + NIC bound to a subnet |
| `nsg` | 04-08 | NSG with dynamic allow rules + association |
| `vm-stack` | 04-09, 04-10 | full RG → VNet → NSG → IP → NIC → VM stack |
