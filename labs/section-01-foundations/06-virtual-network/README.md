# 06 — Virtual Network

Create an Azure Virtual Network with two subnets in one block. This lab introduces
networking — the backbone of almost every later lab.

```bash
terraform init && terraform apply
```

The two subnets are defined **inline** inside the `azurerm_virtual_network` resource.
Lab 12 shows the more flexible "subnet as a separate resource" pattern.
