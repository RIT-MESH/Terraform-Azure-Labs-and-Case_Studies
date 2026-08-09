variable "rules" {
  type = list(object({
    name     = string
    priority = number
    port     = number
  }))
  default = [
    { name = "Allow-SSH",   priority = 200, port = 22 },
    { name = "Allow-HTTPS", priority = 210, port = 443 },
  ]
}

variable "ip_configs" {
  type = list(object({
    name      = string
    primary   = bool
    static_ip = string
  }))
  default = [
    { name = "ipconfig-1", primary = true,  static_ip = "172.22.0.10" },
    { name = "ipconfig-2", primary = false, static_ip = "172.22.0.11" },
  ]
}
