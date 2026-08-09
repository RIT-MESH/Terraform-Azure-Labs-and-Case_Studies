variable "container_count" {
  type    = number
  default = 3
  validation {
    condition     = var.container_count > 0 && var.container_count <= 10
    error_message = "Keep between 1 and 10."
  }
}
