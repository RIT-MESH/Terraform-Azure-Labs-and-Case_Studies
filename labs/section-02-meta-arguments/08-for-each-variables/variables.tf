variable "subnets" {
  type = map(object({
    prefix = string
    nsg    = bool
  }))
}
