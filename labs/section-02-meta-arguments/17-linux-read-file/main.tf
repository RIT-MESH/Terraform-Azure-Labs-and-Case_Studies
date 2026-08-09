# Lab 17 — reading a local file with file() / fileexists().
# file() and filebase64() read a file from the lab folder at plan/apply time.
# Here we read a public SSH key from id_rsa.pub and feed it to the VM.
terraform {
  required_version = ">= 1.5.0"
  required_providers { azurerm = { source = "hashicorp/azurerm", version = "~> 3.70" } }
}
provider "azurerm" { features {} }

locals {
  # fileexists() guards against the file being absent (avoids a hard error).
  # If id_rsa.pub exists, read it; otherwise fall back to a placeholder.
  ssh_pubkey = fileexists("id_rsa.pub") ? file("id_rsa.pub") : "ssh-rsa REPLACE_ME"
}

resource "azurerm_resource_group" "this" {
  name     = "rg-linux-readfile"
  location = "eastus"
}

resource "azurerm_virtual_network" "this" {
  name                = "vnet-linux-readfile"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  address_space       = ["10.230.0.0/16"]
}

resource "azurerm_subnet" "web" {
  name                 = "snet-web"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = ["10.230.1.0/24"]
}

resource "azurerm_network_interface" "web" {
  name                = "nic-readfile"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  ip_configuration {
    name                          = "ipconfig"
    subnet_id                     = azurerm_subnet.web.id
    private_ip_address_allocation = "Dynamic"
  }
}

# admin_ssh_key uses the file contents read above.
resource "azurerm_linux_virtual_machine" "web" {
  name                  = "vm-readfile"
  location              = azurerm_resource_group.this.location
  resource_group_name   = azurerm_resource_group.this.name
  size                  = "Standard_B1s"
  admin_username        = "azureadmin"
  network_interface_ids = [azurerm_network_interface.web.id]
  admin_ssh_key {
    username   = "azureadmin"
    public_key = local.ssh_pubkey
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
