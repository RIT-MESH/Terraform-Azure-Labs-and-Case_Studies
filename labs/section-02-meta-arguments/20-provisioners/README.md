# 20 — Provisioners

Provisioners run scripts **at create/destroy time**. They are a **last resort**: they
are not idempotent, not visible in `plan`, and fail the run if they error. Prefer
`custom_data`/cloud-init or a configuration tool (Ansible, Chef, etc.).

This lab demonstrates a `remote-exec` provisioner over SSH that prints the OS release —
only to show the mechanics. Notice `connection {}` and the `self` reference.
