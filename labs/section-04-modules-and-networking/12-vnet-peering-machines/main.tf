# Lab 12 — one VM per VNet (so we can test connectivity after peering in lab 13).
#  - hub: rg/VNet/subnet/NIC/VM in eastus (10.22.0.0/16).
#  - spoke: rg/VNet/subnet/NIC/VM in westus2 (10.23.0.0/16).
# After peering, the hub VM can ping the spoke VM's private IP.
variable "admin_ssh_key" { type = string, sensitive = true }

resource "azurerm_resource_group" "hub" {
  name     = "rg-peer-hub"
  location = "eastus"
}
resource "azurerm_virtual_network" "hub" {
  name                = "vnet-peer-hub"
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name
  address_space       = ["10.22.0.0/16"]
}
resource "azurerm_subnet" "hub" {
  name                 = "snet-hub"
  resource_group_name  = azurerm_resource_group.hub.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = ["10.22.1.0/24"]
}
resource "azurerm_network_interface" "hub" {
  name                = "nic-hub"
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name
  ip_configuration {
    name                          = "ipconfig"
    subnet_id                     = azurerm_subnet.hub.id
    private_ip_address_allocation = "Dynamic"
  }
}
resource "azurerm_linux_virtual_machine" "hub" {
  name                  = "vm-hub"
  location              = azurerm_resource_group.hub.location
  resource_group_name   = azurerm_resource_group.hub.name
  size                  = "Standard_B1s"
  admin_username        = "azureadmin"
  network_interface_ids = [azurerm_network_interface.hub.id]
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

resource "azurerm_resource_group" "spoke" {
  name     = "rg-peer-spoke"
  location = "westus2"
}
resource "azurerm_virtual_network" "spoke" {
  name                = "vnet-peer-spoke"
  location            = azurerm_resource_group.spoke.location
  resource_group_name = azurerm_resource_group.spoke.name
  address_space       = ["10.23.0.0/16"]
}
resource "azurerm_subnet" "spoke" {
  name                 = "snet-spoke"
  resource_group_name  = azurerm_resource_group.spoke.name
  virtual_network_name = azurerm_virtual_network.spoke.name
  address_prefixes     = ["10.23.1.0/24"]
}
resource "azurerm_network_interface" "spoke" {
  name                = "nic-spoke"
  location            = azurerm_resource_group.spoke.location
  resource_group_name = azurerm_resource_group.spoke.name
  ip_configuration {
    name                          = "ipconfig"
    subnet_id                     = azurerm_subnet.spoke.id
    private_ip_address_allocation = "Dynamic"
  }
}
resource "azurerm_linux_virtual_machine" "spoke" {
  name                  = "vm-spoke"
  location              = azurerm_resource_group.spoke.location
  resource_group_name   = azurerm_resource_group.spoke.name
  size                  = "Standard_B1s"
  admin_username        = "azureadmin"
  network_interface_ids = [azurerm_network_interface.spoke.id]
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

output "hub_private_ip"   { value = azurerm_network_interface.hub.private_ip_address }
output "spoke_private_ip" { value = azurerm_network_interface.spoke.private_ip_address }
