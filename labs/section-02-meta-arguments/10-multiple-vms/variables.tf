variable "vm_count"      { type = number, default = 2 }
variable "admin_username" { type = string, default = "azureadmin" }
variable "admin_ssh_key"  { type = string, sensitive = true }
