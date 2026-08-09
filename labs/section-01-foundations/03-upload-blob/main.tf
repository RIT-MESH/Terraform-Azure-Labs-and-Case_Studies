locals {
  region  = "eastus"
  rg_name = "rg-blob-foundation"
  st_name = lower("stblobfound${substr(md5(timestamp()), 0, 6)}") # globally-unique name
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

# A container groups blobs. `container_access_type = "private"` means only
# authorized requests can read its blobs (good default for real data).
resource "azurerm_storage_container" "uploads" {
  name                  = "uploads"
  storage_account_name  = azurerm_storage_account.this.name   # just the name string
  container_access_type = "private"
}

# A Block blob for small text/file uploads. `source_content` uploads inline text
# (use `source = "./file.png"` to upload a local file instead).
resource "azurerm_storage_blob" "hello" {
  name                   = "hello.txt"
  storage_account_name    = azurerm_storage_account.this.name
  storage_container_name  = azurerm_storage_container.uploads.name
  type                   = "Block"            # Block = small files; Append/Page are other types
  source_content         = "Hello from Terraform!\nUploaded: ${timestamp()}"
  content_type           = "text/plain"
}

output "blob_url" { value = azurerm_storage_blob.hello.url }
