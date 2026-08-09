# The vm-stack module: a reusable RG → VNet → subnet → NSG → public IP → NIC → VM stack.
# A module's main.tf contains the resources; inputs come from variables.tf, outputs
# are declared in outputs.tf. Callers see ONLY the variables and outputs.
terraform {
  required_version = ">= 1.5.0"
  required_providers { azurerm = { source = "hashicorp/azurerm", version = "~> 3.70" } }
}

# Resource group — every Azure resource lives in one. name is built from name_prefix.
resource "azurerm_resource_group" "this" {
  name     = "rg-${var.name_prefix}"
  location = var.location
  tags     = var.tags
}

# Virtual network using the provided address_space.
resource "azurerm_virtual_network" "this" {
  name                = "vnet-${var.name_prefix}"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  address_space       = var.vnet_address_space
  tags                = var.tags
}

# One web subnet (its own resource → more flexible than inline subnets).
resource "azurerm_subnet" "web" {
  name                 = "snet-${var.name_prefix}-web"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [var.subnet_prefix]
}

# NSG allowing SSH so you can reach the VM. In prod, tighten the source IP.
resource "azurerm_network_security_group" "web" {
  name                = "nsg-${var.name_prefix}"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  tags                = var.tags
  security_rule {
    name                       = "Allow-SSH"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Bind the NSG to the subnet so its rules protect that subnet.
resource "azurerm_subnet_network_security_group_association" "web" {
  subnet_id                 = azurerm_subnet.web.id
  network_security_group_id = azurerm_network_security_group.web.id
}

# A static public IP for the VM (so its address won't change on stop/start).
resource "azurerm_public_ip" "web" {
  name                = "pip-${var.name_prefix}"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  allocation_method   = "Static"
  sku                = "Standard"
  tags               = var.tags
}

# NIC ties the VM to the subnet AND the public IP.
resource "azurerm_network_interface" "web" {
  name                = "nic-${var.name_prefix}"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  tags                = var.tags
  ip_configuration {
    name                          = "ipconfig"
    subnet_id                     = azurerm_subnet.web.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.web.id
  }
}

# The Linux VM. custom_data is optional (from the caller); admin_ssh_key is required.
resource "azurerm_linux_virtual_machine" "web" {
  name                  = "vm-${var.name_prefix}"
  location              = azurerm_resource_group.this.location
  resource_group_name   = azurerm_resource_group.this.name
  size                  = var.vm_size
  admin_username        = var.admin_username
  network_interface_ids = [azurerm_network_interface.web.id]
  tags                  = var.tags
  custom_data           = var.custom_data   # base64 cloud-init, "" if not provided

  admin_ssh_key {
    username   = var.admin_username
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
