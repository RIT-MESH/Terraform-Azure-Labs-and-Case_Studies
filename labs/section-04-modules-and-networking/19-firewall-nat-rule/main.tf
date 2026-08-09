variable "workload_private_ip" { type = string }

resource "azurerm_resource_group" "this" {
  name     = "rg-fw-nat"
  location = "eastus"
}

resource "azurerm_virtual_network" "hub" {
  name                = "vnet-hub-fw-nat"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  address_space       = ["10.31.0.0/16"]
}

resource "azurerm_subnet" "firewall" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = ["10.31.0.0/26"]
}

resource "azurerm_public_ip" "fw" {
  name                = "pip-fw-nat"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  allocation_method   = "Static"
  sku                = "Standard"
}

resource "azurerm_firewall" "this" {
  name                = "fw-app1-nat"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  sku_name            = "AZFW_VNet"
  sku_tier            = "Standard"
  ip_configuration {
    name                 = "ipconfig"
    subnet_id            = azurerm_subnet.firewall.id
    public_ip_address_id = azurerm_public_ip.fw.id
  }

  nat_rule_collection {
    name     = "nat-ssh"
    priority = 100
    action   = "Dnat"
    rule {
      name                  = "ssh-to-workload"
      source_addresses      = ["*"]
      destination_ports     = ["22"]
      destination_addresses = [azurerm_public_ip.fw.ip_address]
      translated_port       = "22"
      translated_address    = var.workload_private_ip
      protocols             = ["TCP"]
    }
  }
}

output "fw_public_ip" { value = azurerm_public_ip.fw.ip_address }
