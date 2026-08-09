variable "existing_sa_name" {
  type        = string
  description = "Storage account that already exists in Azure (created outside Terraform)."
}

variable "existing_rg_name" {
  type = string
}
