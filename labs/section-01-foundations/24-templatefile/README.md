# 24 — `templatefile()` (advanced)

`templatefile(path, vars)` renders a local file as a Terraform template, substituting the
`vars` map. Use it to keep large cloud-init / scripts out of `.tf` and parameterise them.

This lab renders `cloud-init.tpl` with a hostname and a list of packages, then passes
the result (base64) to a Linux VM's `custom_data`.

Addressing: VNet `172.17.0.0/20`, subnet `172.17.0.0/26`.
