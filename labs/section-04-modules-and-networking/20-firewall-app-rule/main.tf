resource "azurerm_resource_group" "this" {
  name     = "rg-fw-app"
  location = "eastus"
}

resource "azurerm_virtual_network" "hub" {
  name                = "vnet-hub-fw-app"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  address_space       = ["10.32.0.0/16"]
}

resource "azurerm_subnet" "firewall" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = ["10.32.0.0/26"]
}

resource "azurerm_public_ip" "fw" {
  name                = "pip-fw-app"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  allocation_method   = "Static"
  sku                = "Standard"
}

resource "azurerm_firewall" "this" {
  name                = "azfw-app"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  sku_name            = "AZFW_VNet"
  sku_tier            = "Standard"
  ip_configuration {
    name                 = "ipconfig"
    subnet_id            = azurerm_subnet.firewall.id
    public_ip_address_id = azurerm_public_ip.fw.id
  }

  application_rule_collection {
    name     = "app-allow"
    priority = 100
    action   = "Allow"
    rule {
      name             = "allow-updates"
      source_addresses = ["10.32.1.0/24"]
      protocols {
        type = "Http"
        port = 80
      }
      protocols {
        type = "Https"
        port = 443
      }
      target_fqdns = ["*.ubuntu.com", "github.com", "*.githubusercontent.com"]
    }
  }
}

output "fw_public_ip" { value = azurerm_public_ip.fw.ip_address }
