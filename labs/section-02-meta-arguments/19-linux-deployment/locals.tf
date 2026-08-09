locals {
  ssh_pubkey = fileexists("id_rsa.pub") ? file("id_rsa.pub") : "ssh-rsa REPLACE_ME"
  rg         = "rg-linux-deploy"
}
