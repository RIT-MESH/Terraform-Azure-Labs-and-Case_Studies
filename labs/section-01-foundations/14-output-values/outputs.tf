# outputs.tf — `output` blocks expose values after apply and to other configs.
# `sensitive = true` masks the value in plan/apply logs (it still prints on demand
# via `terraform output <name>`). Use it for keys/passwords.
output "storage_account_name" {
  value       = azurerm_storage_account.this.name
  description = "Name of the storage account."
}

output "primary_blob_endpoint" {
  value = azurerm_storage_account.this.primary_blob_endpoint
}

output "primary_access_key" {
  value     = azurerm_storage_account.this.primary_access_key
  sensitive = true   # won't appear in plain text in the terminal output
}
