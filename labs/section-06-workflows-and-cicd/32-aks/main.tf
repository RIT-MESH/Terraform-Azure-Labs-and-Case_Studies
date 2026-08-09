variable "ssh_public_key" { type = string, sensitive = true }

resource "azurerm_resource_group" "this" {
  name     = "rg-aks"
  location = "eastus"
}

resource "azurerm_kubernetes_cluster" "this" {
  name                = "aks-cluster"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  dns_prefix          = "aks-cluster"
  kubernetes_version  = "1.27"

  default_node_pool {
    name           = "systempool"
    node_count     = 1
    vm_size        = "Standard_B2s"
    os_disk_size_gb = 30
    only_critical_addons_enabled = true
  }

  identity {
    type = "SystemAssigned"
  }

  linux_profile {
    admin_username = "azureadmin"
    ssh_key {
      key_data = var.ssh_public_key
    }
  }

  network_profile {
    network_plugin = "azure"
    service_cidr   = "10.43.0.0/16"
    dns_service_ip = "10.43.0.10"
  }
}

output "cluster_name" { value = azurerm_kubernetes_cluster.this.name }
output "cluster_id"   { value = azurerm_kubernetes_cluster.this.id }
