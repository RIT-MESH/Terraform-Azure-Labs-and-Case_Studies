# Lab 23 — App Gateway path-based routing.
# One listener, three backend pools: /images/* → pool1, /video/* → pool2, default →
# pool3. The url_path_map + path_rule blocks implement the routing. This is the
# building block for hosting several services behind ONE domain/hostname.
# VNet 172.24.0.0/20; appgw subnet 172.24.0.0/26; backends subnet 172.24.0.64/26.
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
    runcmd: [ "systemctl enable --now nginx" ]
  EOT
}

resource "azurerm_resource_group" "this" {
  name     = "rg-appgw-path"
  location = "eastus"
}

resource "azurerm_virtual_network" "this" {
  name                = "vnet-appgw-path"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  address_space       = ["172.24.0.0/20"]
}

resource "azurerm_subnet" "appgw" {
  name                 = "snet-appgw"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = ["172.24.0.0/26"]
}

resource "azurerm_subnet" "backend" {
  name                 = "snet-backend"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = ["172.24.0.64/26"]
}

resource "azurerm_network_interface" "backend" {
  count               = 3
  name                = "nic-appgw-path-be-${count.index}"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  ip_configuration {
    name                          = "ipconfig"
    subnet_id                     = azurerm_subnet.backend.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "backend" {
  count               = 3
  name                = "vm-appgw-path-be-${count.index}"
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

resource "azurerm_public_ip" "appgw" {
  name                = "pip-appgw-path"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  allocation_method   = "Static"
  sku                = "Standard"
}

resource "azurerm_application_gateway" "this" {
  name                = "appgw-path"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location

  sku { name = "Standard_v2", tier = "Standard_v2", capacity = 1 }

  gateway_ip_configuration {
    name      = "ipconfig"
    subnet_id = azurerm_subnet.appgw.id
  }

  frontend_port {
    name = "http"
    port = 80
  }

  frontend_ip_configuration {
    name                 = "fe"
    public_ip_address_id = azurerm_public_ip.appgw.id
  }

  backend_address_pool {
    name = "be-images"
    ip_addresses = [azurerm_network_interface.backend[0].private_ip_address]
  }
  backend_address_pool {
    name = "be-video"
    ip_addresses = [azurerm_network_interface.backend[1].private_ip_address]
  }
  backend_address_pool {
    name = "be-default"
    ip_addresses = [azurerm_network_interface.backend[2].private_ip_address]
  }

  backend_http_settings {
    name                  = "http-settings"
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
  }

  http_listener {
    name                           = "listener"
    frontend_ip_configuration_name = "fe"
    frontend_port_name             = "http"
    protocol                       = "Http"
  }

  # Path-based rule: one listener, three paths.
  request_routing_rule {
    name               = "path-rule"
    rule_type          = "PathBasedRouting"
    http_listener_name = "listener"
    url_path_map_name  = azurerm_application_gateway.this.url_path_map_name
    priority           = 1
  }

  url_path_map {
    name                               = "urlpaths"
    default_backend_address_pool_name  = "be-default"
    default_backend_http_settings_name = "http-settings"

    path_rule {
      name                       = "images"
      paths                       = ["/images/*"]
      backend_address_pool_name  = "be-images"
      backend_http_settings_name = "http-settings"
    }
    path_rule {
      name                       = "video"
      paths                       = ["/video/*"]
      backend_address_pool_name  = "be-video"
      backend_http_settings_name = "http-settings"
    }
  }
}

output "appgw_public_ip" { value = azurerm_public_ip.appgw.ip_address }
