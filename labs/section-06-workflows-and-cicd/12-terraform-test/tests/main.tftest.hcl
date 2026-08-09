run "plan_has_one_storage_account" {
  command = plan

  assert {
    condition     = length(plan.planned_values.azurerm_storage_account) == 1
    error_message = "expected exactly one storage account in the plan"
  }
}

run "storage_uses_standard_tier" {
  command = plan

  assert {
    condition     = plan.planned_values.azurerm_storage_account.this.account_tier == "Standard"
    error_message = "storage account tier should be Standard"
  }
}
