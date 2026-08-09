# Lab 16 — hub + workload VM for the Azure Firewall labs (17-20).
#  - rg-fw with vnet-hub-fw (10.28.0.0/16).
#  - AzureFirewallSubnet (10.28.0.0/26) — where the firewall will live.
#  - a workload subnet + a Linux VM (the thing the firewall will protect/NAT to).
# Outputs the workload/firewall subnet ids and vnet id for labs 17-20.
variable "admin_ssh_key" { type = string, sensitive = true }

resource "azurerm_resource_group" "this" {
  name     = "rg-fw"
  location = "eastus"
}

resource "azurerm_virtual_network" "hub" {
  name                = "vnet-hub-fw"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  address_space       = ["10.28.0.0/16"]
}

resource "azurerm_subnet" "firewall" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = ["10.28.0.0/26"]
}

resource "azurerm_subnet" "workload" {
  name                 = "snet-workload"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = ["10.28.1.0/24"]
}

resource "azurerm_network_interface" "vm" {
  name                = "nic-fw-vm"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  ip_configuration {
    name                          = "ipconfig"
    subnet_id                     = azurerm_subnet.workload.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                  = "vm-fw-workload"
  location              = azurerm_resource_group.this.location
  resource_group_name   = azurerm_resource_group.this.name
  size                  = "Standard_B1s"
  admin_username        = "azureadmin"
  network_interface_ids = [azurerm_network_interface.vm.id]
  admin_ssh_key {
    username   = "azureadmin"
    public_key = var.admin_ssh_key
  }
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
}

output "workload_subnet_id" { value = azurerm_subnet.workload.id }
output "firewall_subnet_id" { value = azurerm_subnet.firewall.id }
output "vnet_id"            { value = azurerm_virtual_network.hub.id }
