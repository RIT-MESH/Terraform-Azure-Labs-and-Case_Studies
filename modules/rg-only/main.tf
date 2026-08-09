# rg-only module — a single resource group. The simplest possible module: one input contract (name+location), one resource, one output (id+name).
resource "azurerm_resource_group" "this" {
  name     = var.name
  location = var.location
  tags     = var.tags
}
