# Lab 16 — a VM with a system-assigned managed identity + least-privilege RBAC.
#  - identity { type = "SystemAssigned" } gives the VM an Azure identity (no secret).
#  - azurerm_role_assignment grants that identity ONLY "Storage Blob Data Reader" on
#    ONE storage account. From inside the VM you can read blobs using Azure RBAC —
#    no SAS, no key. That's least privilege.
terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = { source = "hashicorp/azurerm", version = "~> 3.70" }
  }
}
provider "azurerm" { features {} }

variable "admin_ssh_key" { type = string, sensitive = true }

resource "azurerm_resource_group" "this" {
  name     = "rg-vm-mi"
  location = "eastus"
}

# A storage account + container the VM will be allowed to read.
resource "azurerm_storage_account" "this" {
  name                     = lower("stvmi${substr(md5(timestamp()), 0, 6)}")
  resource_group_name      = azurerm_resource_group.this.name
  location                 = azurerm_resource_group.this.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "data" {
  name                  = "data"
  storage_account_name  = azurerm_storage_account.this.name
  container_access_type = "private"
}

resource "azurerm_virtual_network" "this" {
  name                = "vnet-vm-mi"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  address_space       = ["172.27.0.0/20"]
}

resource "azurerm_subnet" "web" {
  name                 = "snet-web"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = ["172.27.0.0/26"]
}

resource "azurerm_network_interface" "vm" {
  name                = "nic-vm-mi"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  ip_configuration {
    name                          = "ipconfig"
    subnet_id                     = azurerm_subnet.web.id
    private_ip_address_allocation = "Dynamic"
  }
}

# VM with a system-assigned managed identity.
resource "azurerm_linux_virtual_machine" "vm" {
  name                  = "vm-mi"
  location              = azurerm_resource_group.this.location
  resource_group_name   = azurerm_resource_group.this.name
  size                  = "Standard_B1s"
  admin_username        = "azureadmin"
  network_interface_ids = [azurerm_network_interface.vm.id]
  admin_ssh_key {
    username   = "azureadmin"
    public_key = var.admin_ssh_key
  }
  identity { type = "SystemAssigned" }
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

# Grant the VM's identity ONLY blob-reader on this one account.
resource "azurerm_role_assignment" "vm_blob_reader" {
  scope                = azurerm_storage_account.this.id
  role_definition_name = "Storage Blob Data Reader"
  principal_id         = azurerm_linux_virtual_machine.vm.identity[0].principal_id
}

output "vm_principal_id" { value = azurerm_linux_virtual_machine.vm.identity[0].principal_id }
output "storage_name"    { value = azurerm_storage_account.this.name }
