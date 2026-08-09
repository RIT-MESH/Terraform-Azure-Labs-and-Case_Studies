terraform {
  required_version = ">= 1.5.0"
  required_providers { azurerm = { source = "hashicorp/azurerm", version = "~> 3.70" } }
}
provider "azurerm" { features {} }

variable "admin_ssh_key" { type = string, sensitive = true }

locals {
  rg   = "rg-templatefile"
  vnet = "172.17.0.0/20"
  snet = "172.17.0.0/26"

  # templatefile(PATH, VARS) renders a file as a Terraform template, substituting
  # the vars map. The template can use %{ for %} and ${ } just like interpolation.
  # Keep big scripts OUT of .tf this way — cleaner and reusable.
  rendered = templatefile("${path.module}/cloud-init.tpl", {
    hostname = "web-templatefile"
    packages = ["nginx", "curl"]
  })
}

resource "azurerm_resource_group" "this" {
  name     = local.rg
  location = "eastus"
}

resource "azurerm_virtual_network" "this" {
  name                = "vnet-templatefile"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  address_space       = [local.vnet]
}

resource "azurerm_subnet" "web" {
  name                 = "snet-web"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [local.snet]
}

resource "azurerm_network_interface" "web" {
  name                = "nic-templatefile"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  ip_configuration {
    name                          = "ipconfig"
    subnet_id                     = azurerm_subnet.web.id
    private_ip_address_allocation = "Dynamic"
  }
}

# custom_data runs cloud-init on first boot. It MUST be base64-encoded; the
# VM decodes it. Here we feed the rendered template.
resource "azurerm_linux_virtual_machine" "web" {
  name                  = "vm-templatefile"
  location              = azurerm_resource_group.this.location
  resource_group_name   = azurerm_resource_group.this.name
  size                  = "Standard_B1s"
  admin_username        = "azureadmin"
  network_interface_ids = [azurerm_network_interface.web.id]
  custom_data           = base64encode(local.rendered)
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

output "rendered_preview" { value = substr(local.rendered, 0, 120) }
