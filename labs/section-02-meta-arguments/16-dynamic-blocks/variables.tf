variable "rules" {
  type = list(object({
    name     = string
    priority = number
    port     = number
  }))
  default = [
    { name = "Allow-HTTP",  priority = 200, port = 80 },
    { name = "Allow-HTTPS", priority = 210, port = 443 },
  ]
}
