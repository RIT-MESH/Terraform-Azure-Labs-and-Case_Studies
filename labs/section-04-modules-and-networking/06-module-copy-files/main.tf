# Lab 06 — the vm-stack module with custom_data (cloud-init) to write files at boot.
terraform {
  required_version = ">= 1.5.0"
  required_providers { azurerm = { source = "hashicorp/azurerm", version = "~> 3.70" } }
}
provider "azurerm" { features {} }

variable "admin_ssh_key" { type = string, sensitive = true }

locals {
  # A cloud-init config that writes /etc/motd and logs the boot.
  cloud_init = <<-EOT
    #cloud-config
    write_files:
      - path: /etc/motd
        content: |
          Provisioned by the section-04 vm-stack module.
          Files copied here at first boot via cloud-init.
    runcmd:
      - echo "boot complete $(date)" >> /var/log/boot-tf.log
  EOT
}

module "stack" {
  source = "../../../modules/vm-stack"
  name_prefix        = "modcopy"
  location           = "eastus"
  admin_ssh_key      = var.admin_ssh_key
  vnet_address_space = ["10.15.0.0/16"]
  subnet_prefix      = "10.15.1.0/24"
  # base64-encode the cloud-init before passing it to custom_data.
  custom_data        = base64encode(local.cloud_init)
}

output "public_ip" { value = module.stack.public_ip }
