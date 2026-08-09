# Lab 21 — Azure Bastion.
# Bastion gives RDP/SSH over TLS (port 443) WITHOUT a public IP on the VM.
# It needs a dedicated subnet literally named "AzureBastionSubnet", /26 or larger.
terraform {
  required_version = ">= 1.5.0"
  required_providers { azurerm = { source = "hashicorp/azurerm", version = "~> 3.70" } }
}
provider "azurerm" { features {} }

variable "admin_password" { type = string, sensitive = true }

resource "azurerm_resource_group" "this" {
  name     = "rg-bastion"
  location = "eastus"
}

resource "azurerm_virtual_network" "this" {
  name                = "vnet-bastion"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  address_space       = ["10.252.0.0/16"]
}

# The workload VM sits here — NO public IP.
resource "azurerm_subnet" "vm" {
  name                 = "snet-vm"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = ["10.252.1.0/24"]
}

# Bastion REQUIRES this exact name and a /26+ prefix.
resource "azurerm_subnet" "bastion" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = ["10.252.2.0/26"]
}

# Bastion needs a public IP (for the 443 listener). The VM does NOT.
resource "azurerm_public_ip" "bastion" {
  name                = "pip-bastion"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  allocation_method   = "Static"
  sku                = "Standard"
}

resource "azurerm_bastion_host" "this" {
  name                = "bas-secure-access"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  ip_configuration {
    name                 = "ipconfig-bastion"
    subnet_id            = azurerm_subnet.bastion.id
    public_ip_address_id = azurerm_public_ip.bastion.id
  }
}

# A private Windows VM (no public IP). Reach it via the Bastion from the portal.
resource "azurerm_network_interface" "vm" {
  name                = "nic-bastion-vm"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  ip_configuration {
    name                          = "ipconfig"
    subnet_id                     = azurerm_subnet.vm.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_windows_virtual_machine" "vm" {
  name                  = "vm-bastion"
  location              = azurerm_resource_group.this.location
  resource_group_name   = azurerm_resource_group.this.name
  network_interface_ids = [azurerm_network_interface.vm.id]
  size                  = "Standard_B1s"
  admin_username        = "azureadmin"
  admin_password        = var.admin_password
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }
  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-azure-edition"
    version   = "latest"
  }
}

output "bastion_dns" { value = azurerm_bastion_host.this.dns_name }
output "vm_name"     { value = azurerm_windows_virtual_machine.vm.name }
