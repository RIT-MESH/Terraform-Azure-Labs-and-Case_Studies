# Lab 07 — Azure Container Instance (ACI).
# The fastest way to run a container in Azure — no orchestrator. One
# azurerm_container_group runs a public nginx image on port 80 with a public IP.
# Good for simple tasks/jobs; for production services use AKS (lab 08).
resource "azurerm_resource_group" "this" {
  name     = "rg-aci"
  location = "eastus"
}

resource "azurerm_container_group" "this" {
  name                = "aci-nginx"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  os_type             = "Linux"
  ip_address_type     = "Public"
  restart_policy      = "Always"

  container {
    name   = "nginx"
    image  = "nginx:1.25-alpine"
    cpu    = "0.5"
    memory = "0.5"

    ports {
      port     = 80
      protocol = "TCP"
    }
  }
}

output "public_ip" { value = azurerm_container_group.this.ip_address }
