# 06 — Modules — copying files to the server

Use `custom_data` (cloud-init) to write files at boot — the recommended, idempotent
alternative to scp + provisioner. This lab deploys the `vm-stack` module and feeds it a
cloud-init snippet via the `custom_data` input.
