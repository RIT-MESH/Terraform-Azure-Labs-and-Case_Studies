variable "location" {
  type    = string
  default = "eastus"
}

variable "subnets" {
  type = map(object({
    prefix = string
    nsg    = bool
  }))
  description = "Subnet definitions keyed by role."
}
