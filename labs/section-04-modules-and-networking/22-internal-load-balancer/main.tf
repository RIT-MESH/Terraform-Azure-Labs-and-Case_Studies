terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = { source = "hashicorp/azurerm", version = "~> 3.70" }
  }
}
provider "azurerm" { features {} }

variable "admin_ssh_key" { type = string, sensitive = true }

locals {
  cloud_init = <<-EOT
    #cloud-config
    package_update: true
    packages: [nginx]
    runcmd:
      - systemctl enable --now nginx
      - echo "<h1>internal backend $(hostname)</h1>" > /var/www/html/index.html
  EOT
}

resource "azurerm_resource_group" "this" {
  name     = "rg-internal-lb"
  location = "eastus"
}

resource "azurerm_virtual_network" "this" {
  name                = "vnet-internal-lb"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  address_space       = ["172.23.0.0/20"]
}

resource "azurerm_subnet" "backend" {
  name                 = "snet-backend"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = ["172.23.0.0/26"]
}

resource "azurerm_subnet" "frontend" {
  name                 = "snet-frontend"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = ["172.23.0.64/26"]
}

resource "azurerm_network_security_group" "web" {
  name                = "nsg-internal-lb"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  security_rule {
    name                       = "Allow-HTTP"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface" "backend" {
  count               = 2
  name                = "nic-internal-be-${count.index}"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  ip_configuration {
    name                          = "ipconfig"
    subnet_id                     = azurerm_subnet.backend.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "backend" {
  count               = 2
  name                = "vm-internal-be-${count.index}"
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

# The LB frontend is a PRIVATE IP in the frontend subnet.
resource "azurerm_lb" "this" {
  name                = "lb-internal"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                          = "fe-internal"
    subnet_id                     = azurerm_subnet.frontend.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "172.23.0.68"
  }
}

resource "azurerm_lb_backend_address_pool" "web" {
  name            = "be-internal"
  loadbalancer_id = azurerm_lb.this.id
}

resource "azurerm_network_interface_backend_address_pool_association" "web" {
  count                   = 2
  network_interface_id    = azurerm_network_interface.backend[count.index].id
  backend_address_pool_id = azurerm_lb_backend_address_pool.web.id
}

resource "azurerm_lb_probe" "http" {
  name            = "http"
  loadbalancer_id = azurerm_lb.this.id
  protocol        = "Http"
  port            = 80
  request_path    = "/"
}

resource "azurerm_lb_rule" "http" {
  name                           = "http"
  loadbalancer_id                = azurerm_lb.this.id
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "fe-internal"
  backend_address_pool_ids        = [azurerm_lb_backend_address_pool.web.id]
  probe_id                       = azurerm_lb_probe.http.id
}

output "lb_private_ip" { value = "172.23.0.68" }
