terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = { source = "hashicorp/azurerm", version = "~> 3.70" }
  }
}
provider "azurerm" { features {} }

locals {
  region  = "eastus"
  rg_name = "rg-blob-foundation"
  st_name = lower("stblobfound${substr(md5(timestamp()), 0, 6)}")
}

resource "azurerm_resource_group" "this" {
  name     = local.rg_name
  location = local.region
}

resource "azurerm_storage_account" "this" {
  name                     = local.st_name
  resource_group_name      = azurerm_resource_group.this.name
  location                 = azurerm_resource_group.this.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"
}

resource "azurerm_storage_container" "uploads" {
  name                  = "uploads"
  storage_account_name  = azurerm_storage_account.this.name
  container_access_type = "private"
}

# Upload a small inline blob.
resource "azurerm_storage_blob" "hello" {
  name                   = "hello.txt"
  storage_account_name    = azurerm_storage_account.this.name
  storage_container_name  = azurerm_storage_container.uploads.name
  type                   = "Block"
  source_content         = "Hello from Terraform!\nUploaded: ${timestamp()}"
  content_type           = "text/plain"
}

output "blob_url" {
  value = azurerm_storage_blob.hello.url
}
