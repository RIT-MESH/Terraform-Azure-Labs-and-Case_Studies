# A VARIABLE typed as map(object(...)) lets callers pass a whole structure.
# This is the production pattern: same code, different shapes per environment.
variable "location" { type = string, default = "eastus" }

variable "subnets" {
  type = map(object({
    prefix = string
    nsg    = bool
  }))
  description = "Subnet definitions keyed by role."
}

resource "azurerm_resource_group" "this" {
  name     = "rg-subnetmap-foundation"
  location = var.location
}

resource "azurerm_virtual_network" "this" {
  name                = "vnet-subnetmap"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  address_space       = ["10.70.0.0/16"]
}

# One subnet per entry in the var.subnets map (values come from terraform.tfvars).
resource "azurerm_subnet" "this" {
  for_each             = var.subnets
  name                 = "snet-${each.key}"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [each.value.prefix]
}
