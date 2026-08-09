output "storage_account_name" {
  value       = azurerm_storage_account.this.name
  description = "Name of the storage account."
}

output "primary_blob_endpoint" {
  value = azurerm_storage_account.this.primary_blob_endpoint
}

output "primary_access_key" {
  value     = azurerm_storage_account.this.primary_access_key
  sensitive = true
}
