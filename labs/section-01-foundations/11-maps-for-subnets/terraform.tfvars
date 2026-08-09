subnets = {
  web  = { prefix = "10.70.1.0/24", nsg = true }
  app  = { prefix = "10.70.2.0/24", nsg = true }
  data = { prefix = "10.70.3.0/24", nsg = false }
}
