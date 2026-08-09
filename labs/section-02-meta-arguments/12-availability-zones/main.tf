variable "admin_ssh_key" { type = string, sensitive = true }

locals {
  zones = [1, 2, 3]
}

resource "azurerm_resource_group" "this" {
  name     = "rg-availzones"
  location = "eastus" # zones require a region that supports them
}

resource "azurerm_virtual_network" "this" {
  name                = "vnet-availzones"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  address_space       = ["10.210.0.0/16"]
}

resource "azurerm_subnet" "web" {
  name                 = "snet-web"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = ["10.210.1.0/24"]
}

resource "azurerm_network_interface" "web" {
  count               = length(local.zones)
  name                = "nic-az-${count.index}"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  ip_configuration {
    name                          = "ipconfig"
    subnet_id                     = azurerm_subnet.web.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "web" {
  count               = length(local.zones)
  name                = "vm-az-${local.zones[count.index]}"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  zone                = tostring(local.zones[count.index])
  size                = "Standard_B1s"
  admin_username      = "azureadmin"
  network_interface_ids = [azurerm_network_interface.web[count.index].id]
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
