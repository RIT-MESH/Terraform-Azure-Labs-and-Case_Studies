variable "admin_ssh_key" { type = string, sensitive = true }

locals {
  cloud_init = <<-EOT
    #cloud-config
    package_update: true
    packages: [nginx]
    runcmd:
      - systemctl enable --now nginx
      - echo "<h1>app-gw backend $(hostname)</h1>" > /var/www/html/index.html
  EOT
}

resource "azurerm_resource_group" "this" {
  name     = "rg-appgw"
  location = "eastus"
}

resource "azurerm_virtual_network" "this" {
  name                = "vnet-appgw"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  address_space       = ["10.26.0.0/16"]
}

resource "azurerm_subnet" "appgw" {
  name                 = "snet-appgw"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = ["10.26.1.0/24"]
}

resource "azurerm_subnet" "backends" {
  name                 = "snet-backends"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = ["10.26.2.0/24"]
}

resource "azurerm_network_interface" "backend" {
  count               = 2
  name                = "nic-appgw-be-${count.index}"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  ip_configuration {
    name                          = "ipconfig"
    subnet_id                     = azurerm_subnet.backends.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "backend" {
  count               = 2
  name                = "vm-appgw-be-${count.index}"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  size                = "Standard_B1s"
  admin_username      = "azureadmin"
  network_interface_ids = [azurerm_network_interface.backend[count.index].id]
  custom_data           = base64encode(local.cloud_init)
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

output "backend_ids"   { value = azurerm_network_interface.backend[*].id }
output "backend_ips"   { value = azurerm_network_interface.backend[*].private_ip_address }
output "appgw_subnet_id" { value = azurerm_subnet.appgw.id }
output "vnet_id"        { value = azurerm_virtual_network.this.id }
