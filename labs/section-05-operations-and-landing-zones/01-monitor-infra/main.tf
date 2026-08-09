variable "admin_ssh_key" { type = string, sensitive = true }

resource "azurerm_resource_group" "this" {
  name     = "rg-monitor"
  location = "eastus"
}

resource "azurerm_virtual_network" "this" {
  name                = "vnet-monitor"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  address_space       = ["10.34.0.0/16"]
}

resource "azurerm_subnet" "web" {
  name                 = "snet-web"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = ["10.34.1.0/24"]
}

resource "azurerm_network_interface" "vm" {
  name                = "nic-monitor"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  ip_configuration {
    name                          = "ipconfig"
    subnet_id                     = azurerm_subnet.web.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                  = "vm-monitor"
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

output "vm_id"   { value = azurerm_linux_virtual_machine.vm.id }
