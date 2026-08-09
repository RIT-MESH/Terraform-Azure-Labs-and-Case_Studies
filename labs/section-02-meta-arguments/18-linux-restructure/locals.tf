# locals.tf — derived values.
locals {
  # Read the SSH key from a local file (falls back if absent).
  ssh_pubkey = fileexists("id_rsa.pub") ? file("id_rsa.pub") : "ssh-rsa REPLACE_ME"
  rg        = "rg-linux-structure"
}
