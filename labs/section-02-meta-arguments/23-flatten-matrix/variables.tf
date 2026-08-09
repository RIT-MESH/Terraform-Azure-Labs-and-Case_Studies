variable "regions" {
  type    = list(string)
  default = ["regionA", "regionB"]
}

variable "tiers" {
  type    = list(string)
  default = ["web", "app"]
}
